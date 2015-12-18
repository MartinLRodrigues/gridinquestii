Unit BNG;

{ British National Grid Unit.

  Copyright (C) 2015 Paul Michell, Michell Computing.

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details. }

{$IFDEF FPC}
  {$MODE OBJFPC}
  {$LONGSTRINGS ON}
{$ENDIF}

Interface

Uses
  SysUtils, Math, Geometry, Geodesy, OSTab;

{ Define British National Grid accuracy level options. }

{ Level 1 simply applies mean deltas instead of using the polynomial correction. }
{ This method yeilds a standard deviation of less than 10m in all directions. }
{           Easting Shift  Northing Shift  Geoid Height  }
{ Min.          86.27         -81.60          43.98      }
{ Mean          96.04         -68.87          51.16      }
{ Max.         103.44         -50.16          57.66      }
{ St. Dev.       3.29           9.45           3.47      }
//{$DEFINE LEVEL1}
{ Level 2 performs 100 kilometer resolution polynomial correction. }
{ This achieves better than 3m horizontal accuracy. }
{ Max Easting Error: 2.790 Max Northing Error: 2.784 Max Geoid Height Error: 2.389 }
//{$DEFINE LEVEL2}
{ Level 3 performs 10 kilometer resolution polynomial correction. }
{ This achieves better than 0.5m horizontal accuracy. }
{ Max Easting Error: 0.371 Max Northing Error: 0.375 Max Geoid Height Error: 0.554 }
//{$DEFINE LEVEL3}
{ Level 4 performs full kilometer resolution polynomial correction. }
{ This achieves better than 0.1m horizontal accuracy. }
{ This is the published method defined by OS but requires 20Mb of additional data tables. }
{$DEFINE LEVEL4}

{ Define to embed the data table within the executable. }
{$DEFINE EMBED}

{ Define to include BNG using GM02 as an additional coordinate system. }
//{$DEFINE BNG02}

Type
  TBNGCoordinateSystem = Object(TCoordinateSystem)
    GMDataPointer: TVerticalTablePointer;
    TNDataPointer: THorizontalTablePointer;
    Constructor Initialize(NewName: String; NewAbbreviation: String; NewDescription: String; NewEPSGNumber: Integer;
                           NewCoordinateType: TCoordinateType; NewAxisOrder: TAxisOrder;
                           NewBounds: TGeodeticBounds; Var NewTNData: THorizontalTable; Var NewGMData: TVerticalTable);
    Function ConvertToGeocentric(Coordinates: TCoordinates): TCoordinates; Virtual;
    Function ConvertFromGeocentric(Coordinates: TCoordinates): TCoordinates; Virtual;
  End;

Var
  GM02GBData: TVerticalTable;
  GM15GBData: TVerticalTable;
  TN02GBData: THorizontalTable;
  TN15GBData: THorizontalTable;
  GRS80Ellipsoid: TEllipsoid;
  BNGGridProjection: TProjection;
  BNG02CoordinateSystem: TBNGCoordinateSystem;
  BNG15CoordinateSystem: TBNGCoordinateSystem;

Const
  BNGBounds: TGeodeticBounds = (Western: -8.74*PI/180; Southern: 49.81*PI/180; Eastern: 1.84*PI/180; Northern: 60.9*PI/180);

Function WGS84CoordinatesToBNGCoordinates(Const Coordinates: TCoordinates; Const TNData: THorizontalTable; Const GMData: TVerticalTable; Out OutputCoordinates: TCoordinates; Out OutputDatum: TVerticalDatumCode): Boolean;
Function BNGCoordinatesToWGS84Coordinates(Const Coordinates: TCoordinates; Const TNData: THorizontalTable; Const GMData: TVerticalTable; Out OutputCoordinates: TCoordinates; Out OutputDatum: TVerticalDatumCode): Boolean;

Implementation

{ Embed the required data tables using resource files. }
{$IFDEF EMBED}
  {$IFDEF LEVEL2}
    {$IFDEF Darwin}
      {$IFDEF BNG02}
        {$R TN02GB100.res}
        {$R GM02GB100.res}
      {$ENDIF}
      {$R TN15GB100.res}
      {$R GM15GB100.res}
    {$ELSE}
      {$IFDEF BNG02}
        {$R TN02GB100.rc}
        {$R GM02GB100.rc}
      {$ENDIF}
      {$R TN15GB100.rc}
      {$R GM15GB100.rc}
    {$ENDIF}
  {$ENDIF}
  {$IFDEF LEVEL3}
    {$IFDEF Darwin}
      {$IFDEF BNG02}
        {$R TN02GB10.res}
        {$R GM02GB10.res}
      {$ENDIF}
      {$R TN15GB10.res}
      {$R GM15GB10.res}
    {$ELSE}
      {$IFDEF BNG02}
        {$R TN02GB10.rc}
        {$R GM02GB10.rc}
      {$ENDIF}
      {$R TN15GB10.rc}
      {$R GM15GB10.rc}
    {$ENDIF}
  {$ENDIF}
  {$IFDEF LEVEL4}
    {$IFDEF Darwin}
      {$IFDEF BNG02}
        {$R TN02GB.res}
        {$R GM02GB.res}
      {$ENDIF}
      {$R TN15GB.res}
      {$R GM15GB.res}
    {$ELSE}
      {$IFDEF BNG02}
        {$R TN02GB.rc}
        {$R GM02GB.rc}
      {$ENDIF}
      {$R TN15GB.rc}
      {$R GM15GB.rc}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

Var
  ProgramFolder: String;
  TN02FileName: String;
  GM02FileName: String;
  TN15FileName: String;
  GM15FileName: String;
  TN02DataFound: Boolean;
  GM02DataFound: Boolean;
  TN15DataFound: Boolean;
  GM15DataFound: Boolean;

Constructor TBNGCoordinateSystem.Initialize(NewName: String; NewAbbreviation: String; NewDescription: String;
                                            NewEPSGNumber: Integer; NewCoordinateType: TCoordinateType;
                                            NewAxisOrder: TAxisOrder; NewBounds: TGeodeticBounds;
                                            Var NewTNData: THorizontalTable; Var NewGMData: TVerticalTable);
Begin
  Inherited Initialize(NewName, NewAbbreviation, NewDescription, NewEPSGNumber,
                             NewCoordinateType, NewAxisOrder, NewBounds);
  TNDataPointer := @NewTNData;
  GMDataPointer := @NewGMData;
End;

Function TBNGCoordinateSystem.ConvertToGeocentric(Coordinates: TCoordinates): TCoordinates;
Var
  GeodeticCoordinates: TCoordinates;
Begin
  If BNGCoordinatesToWGS84Coordinates(Coordinates, TNDataPointer^, GMDataPointer^, GeodeticCoordinates, LastVerticalDatum) Then
    If WithinGeodeticBounds(GeodeticCoordinates) Then
      Result := GeodeticToGeocentric(GeodeticCoordinates, GRS80Ellipsoid)
    Else
      Begin
        LastVerticalDatum := vdNone;
        Result := NullCoordinates
      End;
End;

Function TBNGCoordinateSystem.ConvertFromGeocentric(Coordinates: TCoordinates): TCoordinates;
Var
  GeodeticCoordinates: TCoordinates;
Begin
  GeodeticCoordinates := GeocentricToGeodetic(Coordinates, GRS80Ellipsoid);
  If WithinGeodeticBounds(GeodeticCoordinates) Then
    If WGS84CoordinatesToBNGCoordinates(GeodeticCoordinates, TNDataPointer^, GMDataPointer^, Result, LastVerticalDatum) Then
      Exit;
  LastVerticalDatum := vdNone;
  Result := NullCoordinates
End;

Function WGS84CoordinatesToBNGCoordinates(Const Coordinates: TCoordinates; Const TNData: THorizontalTable; Const GMData: TVerticalTable; Out OutputCoordinates: TCoordinates; Out OutputDatum: TVerticalDatumCode): Boolean;
Var
{$IFNDEF LEVEL1}Parameters: TInterpolationParameters;{$ENDIF}
  Shifts: TCoordinates;
{$IFDEF LEVEL2}Const GridScale = 100000;{$ENDIF}
{$IFDEF LEVEL3}Const GridScale = 10000;{$ENDIF}
{$IFDEF LEVEL4}Const GridScale = 1000;{$ENDIF}
Begin
  { By default return no vertical datum code. }
  Result := False;
  OutputDatum := vdNone;
  { Full transformation of GRS80/WGS84/ETRS89 value to OSGB36 easting and northing as per OS method. }
  { 1. Perform transverse Mercator projection of initial ellipsoid using OS grid but WGS84 ellipsiod parameters, Lat/Lon MUST be in radians. }
  OutputCoordinates := TransverseMercator(Coordinates, BNGGridProjection);
  { 2. Perform coordinate corrections either from mean shift or from interpolation of the OS data tables. }
{$IFDEF LEVEL1}
  Shifts.Easting := 96.04;
  Shifts.Northing := -68.87;
  Shifts.Altitude := -51.16; { Geoid height is subtracted. }
  Result := True;
{$ELSE}
  Parameters := BilinearGridInterpolationParameters(TNData.Header.Origin, OutputCoordinates, GridScale);
  Shifts := InterpolateHorizontalTable(TNData, Parameters);
  Shifts.Elevation := -InterpolateVerticalTable(GMData, Parameters); { Geoid is below ellipsoid. }
  { Lookup the vertical datum for the current geoid model grid square. }
  With Parameters Do
    OutputDatum := TVerticalDatumCode(GMData.Data(X1, Y1).DatumCode);
  Result := (OutputDatum<>vdNone);
{$ENDIF}
  OutputCoordinates := OutputCoordinates+Shifts;
End;

Function BNGCoordinatesToWGS84Coordinates(Const Coordinates: TCoordinates; Const TNData: THorizontalTable; Const GMData: TVerticalTable; Out OutputCoordinates: TCoordinates; Out OutputDatum: TVerticalDatumCode): Boolean;
{$IFNDEF LEVEL1}
Var
  Parameters: TInterpolationParameters;
  GeodeticCoordinates: TCoordinates;
  PriorCoordinates: TCoordinates;
  Shifts: TCoordinates;
  Iteration: Integer;
Const
  IterationLimit = 6;
  Epsilon: TCoordinate = 0.0001;
{$ENDIF}
{$IFDEF LEVEL2}GridScale = 100000;{$ENDIF}
{$IFDEF LEVEL3}GridScale = 10000;{$ENDIF}
{$IFDEF LEVEL4}GridScale = 1000;{$ENDIF}
Begin
  { Set the initial geodetic coordinates. }
  GeodeticCoordinates := Coordinates;
  { By default return no vertical datum code. }
  Result := False;
  OutputDatum := vdNone;
  {$IFDEF LEVEL1}
  With GeodeticCoordinates Do
    Begin
      Easting := Easting-96.04;
      Northing := Northing+68.87;
      Elevation := Elevation+51.16; { Geoid height is added. }
    End;
  OutputCoordinates := InverseTransverseMercator(GeodeticCoordinates, OSTN02GridProjection);
  Result := True;
  {$ELSE}
  { Prepare for itteration loop. }
  PriorCoordinates := NullCoordinates;
  For Iteration := 1 To IterationLimit Do
    Begin
      Parameters := BilinearGridInterpolationParameters(TNData.Header.Origin, GeodeticCoordinates, GridScale);
      Shifts := InterpolateHorizontalTable(TNData, Parameters);
      Shifts.Elevation := -InterpolateVerticalTable(GMData, Parameters); { Geoid is below ellipsoid. }
      GeodeticCoordinates := Coordinates-Shifts;
      { If convergance has been reached. }
      If (Abs(GeodeticCoordinates.Easting-PriorCoordinates.Easting)<Epsilon) And
         (Abs(GeodeticCoordinates.Northing-PriorCoordinates.Northing)<Epsilon) Then
         Begin
           OutputCoordinates := InverseTransverseMercator(GeodeticCoordinates, BNGGridProjection);
           With Parameters Do
             OutputDatum := TVerticalDatumCode(GMData.Data(X1, Y1).DatumCode);
           Result := (OutputDatum<>vdNone);
           Exit;
         End;
      PriorCoordinates := GeodeticCoordinates;
    End;
  { If no valid solution found. }
  OutputCoordinates := NullCoordinates;
  Raise Exception.Create('Inverse BNG projection failed to converge grid to ETRS89 coordinates.');
  {$ENDIF}
End;

Initialization

ProgramFolder := IncludeTrailingPathDelimiter(ExtractFilePath(GetModuleName(HInstance))); // TODO: Does this work cross-platform? Or is ParamStr(0) better?
{$IFDEF LEVEL1}
TN02DataFound := False;
GM02DataFound := False;
TN15DataFound := False;
GM15DataFound := False;
{$ENDIF}
{$IFDEF LEVEL2}
TN02FileName := ProgramFolder+'TN02GB100.dat';
GM02FileName := ProgramFolder+'GM02GB100.dat';
TN15FileName := ProgramFolder+'TN15GB100.dat';
GM15FileName := ProgramFolder+'GM15GB100.dat';
{$ENDIF}
{$IFDEF LEVEL3}
TN02FileName := ProgramFolder+'TN02GB10.dat';
GM02FileName := ProgramFolder+'GM02GB10.dat';
TN15FileName := ProgramFolder+'TN15GB10.dat';
GM15FileName := ProgramFolder+'GM15GB10.dat';
{$ENDIF}
{$IFDEF LEVEL4}
TN02FileName := ProgramFolder+'TN02GB.dat';
GM02FileName := ProgramFolder+'GM02GB.dat';
TN15FileName := ProgramFolder+'TN15GB.dat';
GM15FileName := ProgramFolder+'GM15GB.dat';
{$ENDIF}

{ Prepare any required data table structures. }
{$IFNDEF LEVEL1}
{$IFDEF BNG02}
TN02GBData.Initialize;
GM02GBData.Initialize;
{$ENDIF}
TN15GBData.Initialize;
GM15GBData.Initialize;
{$ENDIF}

{ Attempt to load the data tables from external files. }
{$IFNDEF LEVEL1}
{$IFDEF BNG02}
TN02DataFound := TN02GBData.LoadFromFile(TN02FileName);
GM02DataFound := GM02GBData.LoadFromFile(GM02FileName);
{$ENDIF}
TN15DataFound := TN15GBData.LoadFromFile(TN15FileName);
GM15DataFound := GM15GBData.LoadFromFile(GM15FileName);
{$ENDIF}

{ If no external data files found, load the tables from the embedded resources. }
{$IFDEF EMBED}
{$IFDEF BNG02}
If Not TN02DataFound Then
  TN02DataFound := TN02GBData.LoadFromResource('TN02GB', 'DATA');
If Not GM02DataFound Then
  GM02DataFound := GM02GBData.LoadFromResource('GM02GB', 'DATA');
{$ENDIF}
If Not TN15DataFound Then
  TN15DataFound := TN15GBData.LoadFromResource('TN15GB', 'DATA');
If Not GM15DataFound Then
  GM15DataFound := GM15GBData.LoadFromResource('GM15GB', 'DATA');
{$ENDIF}

GRS80Ellipsoid.Initialize(6378137.0000, 6356752.314140);
BNGGridProjection.Initialize(0.9996012717, DegToRad(49), DegToRad(-2), 400000, -100000, GRS80Ellipsoid);
{$IFDEF BNG02}
BNG02CoordinateSystem.Initialize('British National Grid (2002)', 'OSGB36',
                                 'OSGB36 / British National Grid (TN02/GM02)', 27700, ctProjected, aoXYZ, BNGBounds, TN02GBData, GM02GBData);
CoordinateSystems.Register(BNG02CoordinateSystem);
{$ENDIF}
BNG15CoordinateSystem.Initialize('British National Grid (2015)', 'OSGB36',
                                 'OSGB36 / British National Grid (TN15/GM15)', 27701, ctProjected, aoXYZ, BNGBounds, TN15GBData, GM15GBData);
CoordinateSystems.Register(BNG15CoordinateSystem);

Finalization

{ Release any required data table structures. }
{$IFNDEF LEVEL1}
{$IFDEF BNG02}
TN02GBData.Release;
GM02GBData.Release;
{$ENDIF}
TN15GBData.Release;
GM15GBData.Release;
{$ENDIF}

End.
