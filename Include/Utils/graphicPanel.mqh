//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Include  1                                                       |
//+------------------------------------------------------------------+
#include <..\Experts\Advisors\MASTER.mq5>
#include <Controls\Defines.mqh>

//+------------------------------------------------------------------+
//| Define Statments to change default dialoge settings              |
//+------------------------------------------------------------------+
#undef CONTROLS_FONT_NAME
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#define CONTROLS_FONT_NAME "Consolas"
#define CONTROLS_DIALOG_COLOR_CLIENT_BG C'0x20,0x20,0x20'

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                             |
//+------------------------------------------------------------------+
// input group "====Panel Inputs====";
static int InpPanelWidth = 260;               // width in pixel
static int InpPanelHeight = 400;              // height in pixel
static int InpPanelFontSize = 10;             // width in pixel
static int InpPanelTextColor = clrWhiteSmoke; // text clr

//+------------------------------------------------------------------+
//| Class CGraphicalPanel                                                                  |
//+------------------------------------------------------------------+
class CGraphicalPanel : public CAppDialog
{
private:
  // private variables

  // labels
  CLabel main_header;
  CLabel tma_period;
  CLabel stop_loss;
  CLabel tma_multiplayer;
  CLabel tma_signal;
  CLabel stoch_signal;
  CLabel lastV;
  CLabel spreadLabel;
  CLabel type_positionLabel;
  CLabel securelPartAfterTMAMiddleFlagLabel;
  CLabel shiftStopLossFlagLabel;

  // buttons
  CButton m_bChangeColor;

  // private methods
  bool CheckInputs();
  bool CreatePanel();

public:
  void CGraphicalPanel();
  void ~CGraphicalPanel();
  bool Oninit();
  void Update();

  // chart event handler lparam ->as a refference
  void PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
};

// constructor
void CGraphicalPanel::CGraphicalPanel(void) {}

// deconstructor
void CGraphicalPanel::~CGraphicalPanel(void) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicalPanel::Oninit(void)
{
  // create panel
  if (!this.CreatePanel())
  {
    return false;
  }

  if (CheckInputs())
  {
    return false;
  }
  return true;
}

void CGraphicalPanel::Update(void)
{

  tma_signal.Text("tma signal:       " + (string)TMA_signal);
  stoch_signal.Text("stoch signal: " + (string)stochSignal);
  lastV.Text("last: " + (string)last);
  type_positionLabel.Text("type_position: " + (string)type_position);
  spreadLabel.Text("spread: " + (string)spread);
  securelPartAfterTMAMiddleFlagLabel.Text("securelPartAfterTMAMiddle: " + (string)securelPartAfterTMAMiddleFlag);
  shiftStopLossFlagLabel.Text("shiftStopLossFlag: " + (string)shiftStopLossFlag);
  spreadLabel.Color(clrWheat);
  return;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicalPanel::CheckInputs(void)
{
  if (InpPanelWidth <= 0)
  {
    Print("Panel width <=0");
    return false;
  }
  if (InpPanelHeight <= 0)
  {
    Print("Panel height <=0");
    return false;
  }
  if (InpPanelFontSize <= 0)
  {
    Print("Panel font size <=0");
    return false;
  }

  return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGraphicalPanel::CreatePanel(void)
{
  // create dialog panel
  this.Create(NULL, "Tie Range EA", 0, 0, 30, InpPanelWidth, InpPanelHeight);

  main_header.Create(NULL, "main_header", 0, 10, 5, 1, 1);
  main_header.Text("Inputs:");
  main_header.Color(clrLime);
  main_header.FontSize(InpPanelFontSize);
  this.Add(main_header);

  tma_period.Create(NULL, "tma_period", 0, 10, 20, 1, 1);
  tma_period.Text("tma period:       " + (string)atr_period);
  tma_period.Color(clrWheat);
  tma_period.FontSize(InpPanelFontSize);
  this.Add(tma_period);

  tma_multiplayer.Create(NULL, "tma_multiplayer", 0, 10, 35, 1, 1);
  tma_multiplayer.Text("tma multiplayer:  " + (string)atr_multiplier);
  tma_multiplayer.Color(clrWheat);
  tma_multiplayer.FontSize(InpPanelFontSize);
  this.Add(tma_multiplayer);

  stop_loss.Create(NULL, "stoploss", 0, 10, 50, 1, 1);
  stop_loss.Text("stoploss:         " + (string)stoploss);
  stop_loss.Color(clrWheat);
  stop_loss.FontSize(InpPanelFontSize);
  this.Add(stop_loss);

  tma_signal.Create(NULL, "tma_signal", 0, 10, 75, 1, 1);
  tma_signal.Text("tma signal:       " + (string)TMA_signal);
  tma_signal.Color(clrWheat);
  tma_signal.FontSize(InpPanelFontSize);
  this.Add(tma_signal);

  stoch_signal.Create(NULL, "stoch_signal", 0, 10, 90, 1, 1);
  stoch_signal.Text("stoch signal: " + (string)stochSignal);
  stoch_signal.Color(clrWheat);
  stoch_signal.FontSize(InpPanelFontSize);
  this.Add(stoch_signal);

  lastV.Create(NULL, "last2", 0, 10, 105, 1, 1);
  lastV.Text("last: " + (string)last);
  lastV.Color(clrWheat);
  lastV.FontSize(InpPanelFontSize);
  this.Add(lastV);


  type_positionLabel.Create(NULL, "type_positionLabel", 0, 10, 125, 1, 1);
  type_positionLabel.Text("type_position: " + (string)type_position);
  type_positionLabel.Color(clrWheat);
  type_positionLabel.FontSize(InpPanelFontSize);
  this.Add(type_positionLabel);

  // flags
  securelPartAfterTMAMiddleFlagLabel.Create(NULL, "securelPartAfterTMAMiddleFlagLabel", 0, 10, 145, 1, 1);
  securelPartAfterTMAMiddleFlagLabel.Text("securelPartAfterTMAMiddle: " + (string)securelPartAfterTMAMiddleFlag);
  securelPartAfterTMAMiddleFlagLabel.Color(clrWheat);
  securelPartAfterTMAMiddleFlagLabel.FontSize(InpPanelFontSize);
  this.Add(securelPartAfterTMAMiddleFlagLabel);

  shiftStopLossFlagLabel.Create(NULL, "shiftStopLossFlagLabel", 0, 10, 165, 1, 1);
  shiftStopLossFlagLabel.Text("shiftStopLossFlag: " + (string)shiftStopLossFlag);
  shiftStopLossFlagLabel.Color(clrWheat);
  shiftStopLossFlagLabel.FontSize(InpPanelFontSize);
  this.Add(shiftStopLossFlagLabel);

  m_bChangeColor.Create(NULL, "bChangeColor", 0, 10, 210, 140, 240);
  m_bChangeColor.Text("Change color:");
  m_bChangeColor.Color(clrRosyBrown);
  m_bChangeColor.ColorBackground(clrRed);
  m_bChangeColor.FontSize(InpPanelFontSize);
  this.Add(m_bChangeColor);

  spreadLabel.Create(NULL, "spread", 0, InpPanelWidth - 120, InpPanelHeight - 80, 1, 1);
  spreadLabel.Text("spread: " + (string)spread);
  spreadLabel.Color(clrWheat);
  spreadLabel.FontSize(InpPanelFontSize);
  this.Add(spreadLabel);

  // run panel
  if (!Run())
  {
    Print("Failed to run custom panel");
    return false;
  }
  // refresh chart
  ChartRedraw();
  return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGraphicalPanel::PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
  // call chart event method of base class
  ChartEvent(id, lparam, dparam, sparam);
}
//+------------------------------------------------------------------+
