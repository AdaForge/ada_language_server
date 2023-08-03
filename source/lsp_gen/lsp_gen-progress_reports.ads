------------------------------------------------------------------------------
--                         Language Server Protocol                         --
--                                                                          --
--                     Copyright (C) 2022-2023, AdaCore                     --
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

with VSS.Strings;

with LSP_Gen.Meta_Models;
with LSP_Gen.Dependencies;

package LSP_Gen.Progress_Reports is

   procedure Write
     (Model : LSP_Gen.Meta_Models.Meta_Model;
      Done  : LSP_Gen.Dependencies.Dependency_Map);

   function Result_Type
     (Model  : LSP_Gen.Meta_Models.Meta_Model;
      Done   : LSP_Gen.Dependencies.Dependency_Map;
      Method : VSS.Strings.Virtual_String) return VSS.Strings.Virtual_String;

end LSP_Gen.Progress_Reports;
