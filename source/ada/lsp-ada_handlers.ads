------------------------------------------------------------------------------
--                         Language Server Protocol                         --
--                                                                          --
--                     Copyright (C) 2018-2023, AdaCore                     --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public  License  distributed  with  this  software;   see  file --
-- COPYING3.  If not, go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
------------------------------------------------------------------------------
--
--  This package provides requests and notifications handler for Ada
--  language.

with Ada.Containers.Hashed_Sets;

with GNATCOLL.VFS;

with GPR2.Project.Tree;

with LSP.Ada_Client_Capabilities;
with LSP.Ada_Configurations;
with LSP.Ada_Context_Sets;
with LSP.Ada_Documents;
with LSP.Ada_File_Sets;
with LSP.Client_Message_Receivers;
with LSP.Server_Message_Visitors;
with LSP.Server_Notification_Receivers;
with LSP.Server_Notifications;
with LSP.Server_Request_Receivers;
with LSP.Server_Requests;
with LSP.Structures;
with LSP.Tracers;
with LSP.Unimplemented_Handlers;

package LSP.Ada_Handlers is

   type Message_Handler
     (Sender : not null access LSP.Client_Message_Receivers
        .Client_Message_Receiver'Class;
      Tracer : not null LSP.Tracers.Tracer_Access) is limited
   new LSP.Server_Message_Visitors.Server_Message_Visitor
     and LSP.Server_Request_Receivers.Server_Request_Receiver
     and LSP.Server_Notification_Receivers.Server_Notification_Receiver
   with private;

   procedure Initialize
     (Self : in out Message_Handler'Class;
      Incremental_Text_Changes : Boolean);
   --  Initialize the message handler and configure it.
   --
   --  Incremental_Text_Changes - activate the support for incremental text
   --  changes.

   function Get_Open_Document
     (Self  : access Message_Handler;
      URI   : LSP.Structures.DocumentUri;
      Force : Boolean := False)
      return LSP.Ada_Documents.Document_Access;
   --  Return the open document for the given URI.
   --  If the document is not opened, then if Force a new document
   --  will be created and must be freed by the user else null will be
   --  returned.

private

   type Load_Project_Status is
     (Valid_Project_Configured,
      Single_Project_Found,
      Alire_Project,
      No_Runtime_Found,
      No_Project_Found,
      Multiple_Projects_Found,
      Invalid_Project_Configured);
   --  Variants for state of the project loaded into the handler:
   --
   --  @value Valid_Project_Configured didChangeConfiguration provided a valid
   --  project
   --
   --  @value Single_Project_Found no project in didChangeConfiguration, but
   --  just one project in Root dir
   --
   --  @value Alire_Project no project in didChangeConfiguration, but Alire
   --  knows what project to use
   --
   --  @value No_Runtime_Found project loaded, but no Ada runtime library was
   --  found
   --
   --  @value No_Project_Found no project in didChangeConfiguration and no
   --  project in Root dir
   --
   --  @value Multiple_Projects_Found no project in didChangeConfiguration and
   --  several projects in Root dir
   --
   --  @value Invalid_Project_Configured didChangeConfiguration provided a
   --  valid project

   subtype Implicit_Project_Loaded is Load_Project_Status range
     No_Project_Found .. Invalid_Project_Configured;
   --  Project status when an implicit project loaded

   --  Container for the predefined source files
   package File_Sets is new Ada.Containers.Hashed_Sets
     (Element_Type        => GNATCOLL.VFS.Virtual_File,
      Hash                => GNATCOLL.VFS.Full_Name_Hash,
      Equivalent_Elements => GNATCOLL.VFS."=",
      "="                 => GNATCOLL.VFS."=");

   type Message_Handler
     (Sender : not null access LSP.Client_Message_Receivers
        .Client_Message_Receiver'Class;
      Tracer : not null LSP.Tracers.Tracer_Access) is limited
   new LSP.Unimplemented_Handlers.Unimplemented_Handler
     and LSP.Server_Message_Visitors.Server_Message_Visitor
     and LSP.Server_Notification_Receivers.Server_Notification_Receiver
   with record
      Client : LSP.Ada_Client_Capabilities.Client_Capability;
      Configuration : LSP.Ada_Configurations.Configuration;

      Contexts : LSP.Ada_Context_Sets.Context_Set;
      --  There is one context in this list per loaded project.
      --  There should always be at least one "project" context - if no .gpr
      --  is known to the server, this context should map to the implicit
      --  project.

      Incremental_Text_Changes : Boolean;
      --  the support for incremental text changes is active

      Indexing_Enabled         : Boolean := True;
      --  Whether to index sources in the background. This should be True
      --  for normal use, and can be disabled for debug or testing purposes.

      Files_To_Index : File_Sets.Set;
      --  Contains any files that need indexing.
      --
      --  Indexing of sources is performed in the background as soon as needed
      --  (typically after a project load), and pre-indexes the Ada source
      --  files, so that subsequent request are fast.
      --  The way the "backgrounding" works is the following:
      --
      --      * each request which should trigger indexing (for instance
      --        project load) adds files to Files_To_Index
      --
      --      * the procedure Index_Files takes care of the indexing; it's also
      --        looking at the queue after each indexing to see if there
      --        are requests pending. If a request is pending, it stops
      --        indexing.
      --
      --      * whenever the server has finished processing a notification
      --        or a requests, it looks at whether Files_To_Index contains
      --        files; if it does, it runs Index_Files

      Total_Files_Indexed  : Natural := 0;
      Total_Files_To_Index : Positive := 1;
      --  These two fields are used to produce a progress bar for the indexing
      --  operations. Total_Files_To_Index starts at 1 so that the progress
      --  bar starts at 0%.

      ----------------------
      -- Project handling --
      ----------------------

      Project_Tree : GPR2.Project.Tree.Object;
      --  The currently loaded project tree

      --  Project_Environment : Environment;
      --  The project environment for the currently loaded project

      Project_Predefined_Sources : LSP.Ada_File_Sets.Indexed_File_Set;
      --  A cache for the predefined sources in the loaded project (typically,
      --  runtime files).

      Project_Status : Load_Project_Status := No_Project_Found;
      --  Status of loading the project

      Project_Dirs_Loaded : File_Sets.Set;
      --  The directories to load in the "implicit project"

   end record;

   overriding procedure On_Server_Request
     (Self  : in out Message_Handler;
      Value : LSP.Server_Requests.Server_Request'Class);

   overriding procedure On_Shutdown_Request
     (Self : in out Message_Handler;
      Id   : LSP.Structures.Integer_Or_Virtual_String);
   overriding procedure On_Server_Notification
     (Self  : in out Message_Handler;
      Value : LSP.Server_Notifications.Server_Notification'Class);

   overriding procedure On_Initialize_Request
     (Self  : in out Message_Handler;
      Id    : LSP.Structures.Integer_Or_Virtual_String;
      Value : LSP.Structures.InitializeParams);

   overriding procedure On_DidChangeConfiguration_Notification
     (Self  : in out Message_Handler;
      Value : LSP.Structures.DidChangeConfigurationParams);

end LSP.Ada_Handlers;
