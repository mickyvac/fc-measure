unit FormAdvancedPlotUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls;

type
  TFormAdvancedPlot = class(TForm)
    Image1: TImage;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormAdvancedPlot: TFormAdvancedPlot;

implementation

{$R *.dfm}

end.
