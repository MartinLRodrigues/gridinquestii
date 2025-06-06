Library GIQ;

{ Grid InQuest II Coordinate Transformation Utility Library.

  Copyright (C) 2015 Paul Michell, Michell Computing.

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by
  the Free Software Foundation; either version 2.1 of the License, or (at your
  option) any later version.

  This library is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details. }

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$LONGSTRINGS ON}
{$ENDIF}

Uses
  {$IFDEF UNIX}
    cthreads, cmem, BaseUnix, Unix,
  {$ENDIF}
  Geodesy, ETRS, BNG, IG, ITM;

{$R *.res}

Function ConvertCoordinates(SourceSRID, TargetSRID: Integer; SourceRevision, TargetRevision: Integer;
                            Var InputCoordinates: TCoordinates; Var OutputCoordinates: TCoordinates;
                            Var DatumCode: Integer): Boolean;{$IFDEF WINDOWS}StdCall;{$ELSE} CDecl;{$ENDIF}
Var
  SourcePointer: TCoordinateSystemPointer;
  TargetPointer: TCoordinateSystemPointer;
  GlobalCoordinates: TCoordinates;
Begin
  Result := False;
  { Find the source and target coordinate systems. }
  With CoordinateSystems Do
    SourcePointer := Pointers(FindSRIDNumber(SourceSRID, SourceRevision));
  With CoordinateSystems Do
    TargetPointer := Pointers(FindSRIDNumber(TargetSRID, TargetRevision));
  { Transform the input coordinates to their global representation. }
  If Assigned(SourcePointer) Then
    Begin
      SourcePointer^.PreferredVerticalDatum := TVerticalDatumCode(DatumCode);
      GlobalCoordinates := SourcePointer^.ConvertToGlobal(InputCoordinates);
    End
  Else
    Exit;
  { If the target system is available. }
  If Assigned(TargetPointer) Then
    Begin
      { Perform any required global type transformations. }
      Case SourcePointer^.GlobalType Of
      gtCartesian:
        If TargetPointer^.GlobalType=gtGeodetic Then
          GlobalCoordinates := GeocentricToGeodetic(GlobalCoordinates, GRS80Ellipsoid);
      gtGeodetic:
        If TargetPointer^.GlobalType=gtCartesian Then
          GlobalCoordinates := GeodeticToGeocentric(GlobalCoordinates, GRS80Ellipsoid);
      End;
      { Transform the global coordinates to the target system. }
      TargetPointer^.PreferredVerticalDatum := TVerticalDatumCode(DatumCode);
      OutputCoordinates := TargetPointer^.ConvertFromGlobal(GlobalCoordinates);
      DatumCode := Integer(TargetPointer^.LastVerticalDatum);
    End
  Else
    Exit;
  Result := True;
End;

Exports
  ConvertCoordinates;

End.

