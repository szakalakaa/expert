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
#include <Controls\CheckBox.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                             |
//+------------------------------------------------------------------+
// input group "====Panel Inputs====";
static int InpPanelWidth = 300;               // width in pixel
static int InpPanelHeight = 360;              // height in pixel
static int InpPanelFontSize = 10;             // width in pixel
static int InpPanelTextColor = clrWhiteSmoke; // text clr
static int btnSize=10;
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
  CLabel type_positionLabel;
  CLabel lotsInPositionLabel;
  CLabel positionOpenPriceLabel;
  CLabel valueLabel;
  CLabel LotsLabel;
  CLabel cntBuyLabel;
  CLabel cntSellLabel;
  CLabel inpMagicLabel;
  CLabel openPosMagicLabel;
  CButton b1;
  CButton b2;
  CButton b3;
  CButton b4;


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
  type_positionLabel.Text((string)type_position);
  lotsInPositionLabel.Text((string)lotsInPosition);
  positionOpenPriceLabel.Text((string)positionOpenPrice);
  cntSellLabel.Text("cntSell: " + (string)cntSell);
  cntBuyLabel.Text("cntBuy: " + (string)cntBuy);
  LotsLabel.Text("Lots: " + (string)Lots);
  openPosMagicLabel.Text("magic pos: " + (string)openPosMagic);
  inpMagicLabel.Text("magic: " + (string)inpMagic);
  PositionSelect(_Symbol);
  valueLabel.Text("value: " + (string)(NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * last, 0)) + " USD");

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

  tma_signal.Create(NULL, "tma_signal", 0, 10, 65, 1, 1);
  tma_signal.Text("tma signal:       " + (string)TMA_signal);
  tma_signal.Color(clrWheat);
  tma_signal.FontSize(InpPanelFontSize);
  this.Add(tma_signal);


  int posY=100;

  type_positionLabel.Create(NULL, "type_positionLabel", 0, 10, posY, 1, 1);
  type_positionLabel.Text((string)type_position);
  type_positionLabel.Color(clrWheat);
  type_positionLabel.FontSize(InpPanelFontSize);
  this.Add(type_positionLabel);

  lotsInPositionLabel.Create(NULL, "lotsInPositionLabel", 0, 60, posY, 1, 1);
  lotsInPositionLabel.Text((string)lotsInPosition);
  lotsInPositionLabel.Color(clrWheat);
  lotsInPositionLabel.FontSize(InpPanelFontSize);
  this.Add(lotsInPositionLabel);

  positionOpenPriceLabel.Create(NULL, "positionOpenPriceLabel", 0, 120, posY, 1, 1);
  positionOpenPriceLabel.Text((string)positionOpenPrice);
  positionOpenPriceLabel.Color(clrWheat);
  positionOpenPriceLabel.FontSize(InpPanelFontSize);
  this.Add(positionOpenPriceLabel);

  int magicY = 160;

  openPosMagicLabel.Create(NULL, "openPosMagicLabel", 0, 10, magicY, 1, 1);
  openPosMagicLabel.Text("magic pos: " + (string)openPosMagic);
  openPosMagicLabel.Color(clrLightBlue);
  openPosMagicLabel.FontSize(InpPanelFontSize);
  this.Add(openPosMagicLabel);

  inpMagicLabel.Create(NULL, "inpMagicLabel", 0, 150, magicY, 1, 1);
  inpMagicLabel.Text("magic: " + (string)inpMagic);
  inpMagicLabel.Color(clrCoral);
  inpMagicLabel.FontSize(InpPanelFontSize);
  this.Add(inpMagicLabel);

  int labelY = 180;

  cntBuyLabel.Create(NULL, "cntBuyLabel", 0, 10, labelY, 1, 1);
  cntBuyLabel.Text("cntBuy: " + (string)cntBuy);
  cntBuyLabel.Color(clrWheat);
  cntBuyLabel.FontSize(InpPanelFontSize);
  this.Add(cntBuyLabel);

  cntSellLabel.Create(NULL, "cntSellLabel", 0, 150, labelY, 1, 1);
  cntSellLabel.Text("cntSell: " + (string)cntSell);
  cntSellLabel.Color(clrWheat);
  cntSellLabel.FontSize(InpPanelFontSize);
  this.Add(cntSellLabel);

  int yButton=210;
  int xBut1=10;
  int xBut2=30;
  int xBut3=50;
  int xBut4=70;

  b1.Create(NULL, "b1", 0, xBut1, yButton, xBut1+btnSize, yButton+btnSize);
  b1.Color(clrAquamarine);
  this.Add(b1);

  b2.Create(NULL, "b2", 0, xBut2, yButton, xBut2+btnSize, yButton+btnSize);
  b2.Color(clrAquamarine);
  this.Add(b2);

  b3.Create(NULL, "b3", 0, xBut3, yButton, xBut3+btnSize, yButton+btnSize);
  b3.Color(clrAquamarine);
  this.Add(b3);

  b4.Create(NULL, "b4", 0, xBut4, yButton, xBut4+btnSize, yButton+btnSize);
  b4.Color(clrAquamarine);
  this.Add(b4);


  LotsLabel.Create(NULL, "LotsLabel", 0, 10, InpPanelHeight - 100, 1, 1);
  LotsLabel.Text("Lots: " + (string)Lots);
  LotsLabel.Color(clrWheat);
  LotsLabel.FontSize(InpPanelFontSize);
  this.Add(LotsLabel);

  valueLabel.Create(NULL, "valueLabel", 0, 10, InpPanelHeight - 80, 1, 1);
  valueLabel.Text("value: " + (string)(NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * last, 0)) + " USD");
  valueLabel.Color(clrWheat);
  valueLabel.FontSize(InpPanelFontSize);
  this.Add(valueLabel);

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
