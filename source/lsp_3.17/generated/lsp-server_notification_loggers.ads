--
--  Copyright (C) <YEAR>, <COPYRIGHT HOLDER>
--
--  SPDX-License-Identifier: MIT
--
--  DON'T EDIT THIS FILE! It was generated from metaModel.json.
--

with LSP.Base_Notification_Loggers;
with LSP.Structures;
with LSP.Server_Notification_Receivers;

package LSP.Server_Notification_Loggers is
   pragma Preelaborate;

   type Server_Notification_Logger is
   new LSP.Base_Notification_Loggers.Base_Notification_Logger and
     LSP.Server_Notification_Receivers.Server_Notification_Receiver with
   null record;

   overriding procedure On_SetTrace_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.SetTraceParams);

   overriding procedure On_Exits_Notification
     (Self : in out Server_Notification_Logger);

   overriding procedure On_Initialized_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.InitializedParams);

   overriding procedure On_DidChangeNotebook_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidChangeNotebookDocumentParams);

   overriding procedure On_DidCloseNotebook_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidCloseNotebookDocumentParams);

   overriding procedure On_DidOpenNotebook_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidOpenNotebookDocumentParams);

   overriding procedure On_DidSaveNotebook_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidSaveNotebookDocumentParams);

   overriding procedure On_DidChange_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidChangeTextDocumentParams);

   overriding procedure On_DidClose_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidCloseTextDocumentParams);

   overriding procedure On_DidOpen_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidOpenTextDocumentParams);

   overriding procedure On_DidSave_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidSaveTextDocumentParams);

   overriding procedure On_WillSave_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.WillSaveTextDocumentParams);

   overriding procedure On_Cancel_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.WorkDoneProgressCancelParams);

   overriding procedure On_DidChangeConfiguration_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidChangeConfigurationParams);

   overriding procedure On_DidChangeWatchedFiles_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidChangeWatchedFilesParams);

   overriding procedure On_DidChangeWorkspaceFolders_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DidChangeWorkspaceFoldersParams);

   overriding procedure On_DidCreateFiles_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.CreateFilesParams);

   overriding procedure On_DidDeleteFiles_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.DeleteFilesParams);

   overriding procedure On_DidRenameFiles_Notification
     (Self  : in out Server_Notification_Logger;
      Value : LSP.Structures.RenameFilesParams);

end LSP.Server_Notification_Loggers;
