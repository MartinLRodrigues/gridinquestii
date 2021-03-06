Unit Progress;

{ GridInQuest II Coordinate Transformation Utility Progress Dialog Unit.

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
  {$MODE ObjFPC}
  {$LONGSTRINGS ON}
{$ENDIF}

Interface

Uses
  Classes, SysUtils, LResources, LCLType, Forms, Controls, Graphics, Dialogs,
  ExtCtrls,  Menus;

Type
  TProgressDisplay = Class
  Private
    FCaption: String;
    FProgress: Integer;
    FProgressForm: TForm;
    FProgressRect: TRect;
    Procedure DoPaint(Sender: TObject);
    Procedure SetProgress(Value: Integer);
  Public
    Constructor Create;
    Destructor Free;
    Procedure Hide;
    Procedure Show(NewCaption: String = '');
    Property Caption: String Read FCaption Write FCaption;
    Property Progress: Integer Read FProgress Write SetProgress;
  End;

Function CreateProgressDisplay(): TProgressDisplay;

Implementation

Function CreateProgressDisplay(): TProgressDisplay;
Begin
  Result := TProgressDisplay.Create;
End;

Constructor TProgressDisplay.Create;
Begin
  FProgressForm := TForm.Create(Nil);
  With FProgressForm Do
    Begin
      BorderStyle := bsNone;
      FormStyle := fsStayOnTop;
      Height := Screen.Height Div 15;
      Width := Screen.Width Div 5;
      Position := poMainFormCenter;
      OnPaint := @DoPaint;
    End;
End;

Destructor TProgressDisplay.Free;
Begin
  FProgressForm.Free;
End;

Procedure TProgressDisplay.Hide;
Begin
  With FProgressForm Do
    If Showing Then
      Begin
        Hide;
        Application.MainForm.Update;
      End;
End;

Procedure TProgressDisplay.Show(NewCaption: String = '');
Begin
  With FProgressForm Do
    Begin
      If NewCaption = '' Then
        FCaption := 'Progress'
      Else
        FCaption := NewCaption;
      If Not Showing Then
        Begin
          Application.MainForm.Update;
          With FProgressRect Do
            Begin
              Left := 5;
              Top := Canvas.TextHeight('X')+10;
              Right := ClientWidth-5;
              Bottom := ClientHeight-5;
            End;
          ShowOnTop;
          {$IFDEF Windows}
            FProgressForm.Update;
          {$ELSE}
            FProgressForm.Update;
            Application.ProcessMessages;
          {$ENDIF}
        End;
    End;
End;

Procedure TProgressDisplay.DoPaint(Sender: TObject);
Var
  CompletedRect: TRect;
  Style: TTextStyle;
Begin
  With FProgressForm.Canvas Do
    Begin
      Brush.Color := clDefault;
      FillRect(FProgressForm.ClientRect);
      Pen.Color := clBlack;
      Rectangle(FProgressForm.ClientRect);
      CompletedRect := FProgressRect;
      With CompletedRect Do
        Right := Left+(FProgress*(Right-Left) Div 100);
      Brush.Color := clMoneyGreen;
      FillRect(CompletedRect);
      Brush.Style := bsClear;
      Rectangle(FProgressRect);
      Font.Color := clBlack;
      Font.Size := 0;
      Font.Quality := fqCleartypeNatural;
      With Style Do
        Begin
          Alignment := taLeftJustify;
          Layout := tlTop;
          SingleLine := True;
          Clipping := True;
          ExpandTabs := False;
          ShowPrefix := False;
          Wordbreak := False;
          Opaque := False;
          SystemFont := False;
          RightToLeft := False;
          EndEllipsis := True;
        End;
      TextRect(FProgressForm.ClientRect, 5, 5, FCaption, Style);
      With Style Do
        Begin
          Alignment := taCenter;
          Layout := tlCenter;
          Font.Size := 12;
        End;
      TextRect(FProgressRect, 0, 0, IntToStr(FProgress)+'%', Style);
    End;
End;

Procedure TProgressDisplay.SetProgress(Value: Integer);
Begin
  If Value<0 Then
    Value := 0;
  If Value>100 Then
    Value := 100;
  If FProgress<>Value Then
    Begin
      FProgress := Value;
      {$IFDEF Windows}
        FProgressForm.Repaint;
      {$ELSE}
        FProgressForm.Repaint;
        Application.ProcessMessages;
      {$ENDIF}
    End;
End;

End.

