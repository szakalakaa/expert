//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Include  1                                                       |
//+------------------------------------------------------------------+
#include <..\Experts\Advisors\MASTER dev.mq5>
#include <Controls\Defines.mqh>

//+------------------------------------------------------------------+
//| Define Statments to change default dialoge settings              |
//+------------------------------------------------------------------+
#undef CONTROLS_FONT_NAME
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#define CONTROLS_FONT_NAME "Consolas"
#define CONTROLS_DIALOG_COLOR_CLIENT_BG 0x150C0C

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
static int InpPanelWidth = 600;               // width in pixel
static int InpPanelHeight = 360;              // height in pixel
static int InpPanelFontSize = 10;             // width in pixel
static int ButtonFontSize = 7;                // width in pixel
static int InpPanelTextColor = clrWhiteSmoke; // text clr
static int btnSize = 40;
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
  CLabel type_positionLabel;
  CLabel lotsInPositionLabel;
  CLabel positionOpenPriceLabel;
  CLabel valueLabel;

  CLabel isMainOrderLabel;
  CLabel isCrossOrderLabel;
  CLabel isStochOrderLabel;
  CLabel timeBlockadeCrossLabel;
  CLabel timeBlockadeMainLabel;

  CLabel stopLossWasSchiftedLabel;
  CLabel currentBalanceLabel;

  CLabel crossAmountLabel;
  CLabel mainAmountLabel;
  CLabel shiftAmountLabel;
  CLabel stochAmountLabel;

  // buttons
  CButton resetCrossTimer;
  CButton resetMainTimer;
  CButton setCrossTimer;
  CButton setMainTimer;
  CButton startExpertButton;
  CButton stopExpertButton;

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

  crossAmountLabel.Text("crossAmount:" + (string)crossAmount);
  mainAmountLabel.Text("mainAmount:  " + (string)mainAmount);
  shiftAmountLabel.Text("shiftAmount:  " + (string)shiftAmount);
  stochAmountLabel.Text("stochAmount:  " + (string)stochAmount);

  if (stopLossWasSchifted)
    stopLossWasSchiftedLabel.Color(clrLightSkyBlue);
  else if (!stopLossWasSchifted)
    stopLossWasSchiftedLabel.Color(clrMistyRose);

  // isCrossOrder
  if (isCrossOrder)
    isCrossOrderLabel.Color(clrLightSkyBlue);
  else if (!isCrossOrder)
    isCrossOrderLabel.Color(clrLightCoral);

  if (timeBlockadeCross)
  {
    timeBlockadeCrossLabel.Color(clrLightSkyBlue);
    timeBlockadeCrossLabel.Text("timeBlockadeCross: " + (string)(crossRemainMinutes));
    isCrossOrderLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
  }
  else
  {
    timeBlockadeCrossLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
    timeBlockadeCrossLabel.Text("");
  }
  // isStochOrder
  if (isStochOrder)
    isStochOrderLabel.Color(clrLightSkyBlue);
  else if (!isStochOrder)
    isStochOrderLabel.Color(clrLightCoral);

  // isMainOrder
  if (isMainOrder)
    isMainOrderLabel.Color(clrLightSkyBlue);
  else if (!isMainOrder)
    isMainOrderLabel.Color(clrLightCoral);

  if (timeBlockadeMain)
  {
    timeBlockadeMainLabel.Color(clrLightSkyBlue);
    timeBlockadeMainLabel.Text("timeBlockadeMain: " + (string)(mainRemainMinutes));
    isMainOrderLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
  }
  else
  {
    timeBlockadeMainLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
    timeBlockadeMainLabel.Text("");
  }

  //
  type_positionLabel.Text((string)type_position);
  lotsInPositionLabel.Text((string)lotsInPosition);
  positionOpenPriceLabel.Text((string)positionOpenPrice);

  PositionSelect(_Symbol);
  valueLabel.Text("value: " + (string)(NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * last, 0)) + " USD");

  // UPPR LEFT CORNER VALUR
  if (currentBalance > 100)
    currentBalanceLabel.Color(clrLightSkyBlue);
  else
    currentBalanceLabel.Color(clrLightCoral);
  currentBalanceLabel.Text((string)currentBalance);

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
  this.Create(NULL, "Tie Range EA", 0, 0, 60, InpPanelWidth, InpPanelHeight);

  int row0 = 5;
  int row1 = 20;
  int row2 = 35;
  int row3 = 50;
  int row4 = 65;

  main_header.Create(NULL, "main_header", 0, 10, row0, 1, 1);
  main_header.Text("Inputs:");
  main_header.Color(clrLime);
  main_header.FontSize(InpPanelFontSize);
  this.Add(main_header);

  currentBalanceLabel.Create(NULL, "currentBalanceLabel", 0, (InpPanelWidth - 70), row0, 1, 1);
  currentBalanceLabel.Text((string)currentBalance);
  currentBalanceLabel.Color(clrWheat);
  this.Add(currentBalanceLabel);

  tma_period.Create(NULL, "tma_period", 0, 10, row1, 1, 1);
  tma_period.Text("tma period:       " + (string)atr_period);
  tma_period.Color(clrWheat);
  tma_period.FontSize(InpPanelFontSize);
  this.Add(tma_period);

  tma_multiplayer.Create(NULL, "tma_multiplayer", 0, 10, row2, 1, 1);
  tma_multiplayer.Text("tma multiplayer:  " + (string)atr_multiplier);
  tma_multiplayer.Color(clrWheat);
  tma_multiplayer.FontSize(InpPanelFontSize);
  this.Add(tma_multiplayer);

  stop_loss.Create(NULL, "stoploss", 0, 10, row3, 1, 1);
  stop_loss.Text("stoploss:         " + (string)stoploss);
  stop_loss.Color(clrWheat);
  stop_loss.FontSize(InpPanelFontSize);
  this.Add(stop_loss);

  int amountX = 250;

  crossAmountLabel.Create(NULL, "crossAmountLabel", 0, amountX, row1, 1, 1);
  crossAmountLabel.Text("crossAmount:  " + (string)crossAmount);
  crossAmountLabel.Color(clrWheat);
  crossAmountLabel.FontSize(InpPanelFontSize);
  this.Add(crossAmountLabel);

  mainAmountLabel.Create(NULL, "mainAmountLabel", 0, amountX, row2, 1, 1);
  mainAmountLabel.Text("mainAmount:  " + (string)mainAmount);
  mainAmountLabel.Color(clrWheat);
  mainAmountLabel.FontSize(InpPanelFontSize);
  this.Add(mainAmountLabel);

  shiftAmountLabel.Create(NULL, "shiftAmountLabel", 0, amountX, row3, 1, 1);
  shiftAmountLabel.Text("shiftAmount:  " + (string)shiftAmount);
  shiftAmountLabel.Color(clrWheat);
  shiftAmountLabel.FontSize(InpPanelFontSize);
  this.Add(shiftAmountLabel);

  stochAmountLabel.Create(NULL, "stochAmountLabel", 0, amountX, row4, 1, 1);
  stochAmountLabel.Text("stochAmount:  " + (string)stochAmount);
  stochAmountLabel.Color(clrWheat);
  stochAmountLabel.FontSize(InpPanelFontSize);
  this.Add(stochAmountLabel);

  int posY = 100;
  type_positionLabel.Create(NULL, "type_positionLabel", 0, 10, posY, 1, 1);
  type_positionLabel.Text((string)type_position);
  type_positionLabel.Color(clrWheat);
  type_positionLabel.FontSize(InpPanelFontSize);
  this.Add(type_positionLabel);

  lotsInPositionLabel.Create(NULL, "lotsInPositionLabel", 0, 120, posY, 1, 1);
  lotsInPositionLabel.Text((string)lotsInPosition);
  lotsInPositionLabel.Color(clrWheat);
  lotsInPositionLabel.FontSize(InpPanelFontSize);
  this.Add(lotsInPositionLabel);

  positionOpenPriceLabel.Create(NULL, "positionOpenPriceLabel", 0, 180, posY, 1, 1);
  positionOpenPriceLabel.Text((string)positionOpenPrice);
  positionOpenPriceLabel.Color(clrWheat);
  positionOpenPriceLabel.FontSize(InpPanelFontSize);
  this.Add(positionOpenPriceLabel);

  int orderY = 120;
  int orderX = 10;

  isCrossOrderLabel.Create(NULL, "isCrossOrderLabel", 0, orderX, orderY, 1, 1);
  isCrossOrderLabel.Text("isCrossOrder");
  isCrossOrderLabel.Color(clrWheat);
  isCrossOrderLabel.FontSize(InpPanelFontSize);
  this.Add(isCrossOrderLabel);

  timeBlockadeCrossLabel.Create(NULL, "timeBlockadeCrossLabel", 0, orderX, orderY, 1, 1);
  // timeBlockadeCrossLabel.Text("timeBlockadeCross: " + (string)crossRemainMinutes);
  timeBlockadeCrossLabel.Color(clrWheat);
  timeBlockadeCrossLabel.FontSize(InpPanelFontSize);
  this.Add(timeBlockadeCrossLabel);

  isStochOrderLabel.Create(NULL, "isStochOrderLabel", 0, orderX, orderY + 20, 1, 1);
  isStochOrderLabel.Text("isStochOrder");
  isStochOrderLabel.Color(clrWheat);
  isStochOrderLabel.FontSize(InpPanelFontSize);
  this.Add(isStochOrderLabel);

  isMainOrderLabel.Create(NULL, "isMainOrderLabel", 0, orderX, +orderY + 40, 1, 1);
  isMainOrderLabel.Text("isMainOrder");
  isMainOrderLabel.Color(clrWheat);
  isMainOrderLabel.FontSize(InpPanelFontSize);
  this.Add(isMainOrderLabel);

  timeBlockadeMainLabel.Create(NULL, "timeBlockadeMainLabel", 0, orderX, orderY + 40, 1, 1);
  // timeBlockadeMainLabel.Text("timeBlockadeMain: " + (string)mainRemainMinutes);
  timeBlockadeMainLabel.Color(clrWheat);
  timeBlockadeMainLabel.FontSize(InpPanelFontSize);
  this.Add(timeBlockadeMainLabel);

  stopLossWasSchiftedLabel.Create(NULL, "stopLossWasSchiftedLabel", 0, 10, 180, 1, 1);
  stopLossWasSchiftedLabel.Text("stopLossWasSchifted");
  stopLossWasSchiftedLabel.Color(clrWheat);
  stopLossWasSchiftedLabel.FontSize(InpPanelFontSize);
  this.Add(stopLossWasSchiftedLabel);

  int btnHeight = 20;
  int btnWidth = 90;
  int btnYRow = 210;
  int xBut1 = 10;
  int yBut1 = btnYRow;

  resetCrossTimer.Create(NULL, "resetCrossTimer", 0, xBut1, yBut1, xBut1 + btnWidth, yBut1 + btnHeight);
  resetCrossTimer.Color(clrBlack);
  ObjectSetInteger(NULL, "resetCrossTimer", OBJPROP_BGCOLOR, clrSeaGreen);
  resetCrossTimer.Text("Reset cross timer");
  resetCrossTimer.FontSize(ButtonFontSize);
  this.Add(resetCrossTimer);

  int yBut2 = btnYRow + 25;
  resetMainTimer.Create(NULL, "resetMainTimer", 0, xBut1, yBut2, xBut1 + btnWidth, yBut2 + btnHeight);
  resetMainTimer.Color(clrBlack);
  ObjectSetInteger(NULL, "resetMainTimer", OBJPROP_BGCOLOR, clrSeaGreen);
  resetMainTimer.Text("Reset main timer");
  resetMainTimer.FontSize(ButtonFontSize);
  this.Add(resetMainTimer);

  int xBut2 = 120;

  setCrossTimer.Create(NULL, "setCrossTimer", 0, xBut2, yBut1, xBut2 + btnWidth, yBut1 + btnHeight);
  setCrossTimer.Color(clrBlack);
  ObjectSetInteger(NULL, "setCrossTimer", OBJPROP_BGCOLOR, clrLightBlue);
  setCrossTimer.Text("Set cross timer");
  setCrossTimer.FontSize(ButtonFontSize);
  this.Add(setCrossTimer);

  setMainTimer.Create(NULL, "setMainTimer", 0, xBut2, yBut2, xBut2 + btnWidth, yBut2 + btnHeight);
  setMainTimer.Color(clrBlack);
  ObjectSetInteger(NULL, "setMainTimer", OBJPROP_BGCOLOR, clrLightBlue);
  setMainTimer.Text("Set main timer");
  setMainTimer.FontSize(ButtonFontSize);
  this.Add(setMainTimer);

  int xBut3 = InpPanelWidth - 230;
  int yBut3 = btnYRow;

  startExpertButton.Create(NULL, "startExpertButton", 0, xBut3, yBut3, xBut3 + btnWidth, yBut3 + btnHeight);
  startExpertButton.Color(clrBlack);
  ObjectSetInteger(NULL, "startExpertButton", OBJPROP_BGCOLOR, clrSkyBlue);
  startExpertButton.Text("Start expert");
  startExpertButton.FontSize(ButtonFontSize);
  this.Add(startExpertButton);

  int xBut4 = InpPanelWidth - 120;
  int yBut4 = btnYRow;

  stopExpertButton.Create(NULL, "stopExpertButton", 0, xBut4, yBut4, xBut4 + btnWidth, yBut4 + btnHeight);
  stopExpertButton.Color(clrBlack);
  ObjectSetInteger(NULL, "stopExpertButton", OBJPROP_BGCOLOR, clrTomato);
  stopExpertButton.Text("Stop expert");
  stopExpertButton.FontSize(ButtonFontSize);
  this.Add(stopExpertButton);

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

void OnChartEvent(const int id,         // Event identifier
                  const long &lparam,   // Event parameter of long type
                  const double &dparam, // Event parameter of double type
                  const string &sparam  // Event parameter of string type
)
{

  if (id == CHARTEVENT_OBJECT_CLICK)
  {

    if (sparam == "resetCrossTimer")
    {
      Print(">>>>  resetCrossTimer clicked!");
      crossRemainMinutes = 0;
      timeBlockadeCross = false;
      createObject(currentTimer, last, 231, clrOrange, "73");
    }

    if (sparam == "resetMainTimer")
    {
      Print(">>>>  resetMainTimer clicked!");
      mainRemainMinutes = 0;
      timeBlockadeMain = false;
      createObject(currentTimer, last, 231, clrOrange, "73");
    }

    if (sparam == "setCrossTimer")
    {
      Print(">>>>  setCrossTimer clicked!");
      crossRemainMinutes  = 50;
      timeBlockadeCross = true;
      createObject(currentTimer, last, 232, clrDarkGray, "2");
    }   
    
    if (sparam == "setMainTimer")
    {
      Print(">>>>  setMainTimer clicked!");
      mainRemainMinutes  = 50;
      timeBlockadeMain = true;
      createObject(currentTimer, last, 232, clrDarkGray, "2");
    }
    if (sparam == "startExpertButton")
    {
      Print(">>>>  startExpert clicked!");
      stopExpert = false;
    }
    if (sparam == "stopExpertButton")
    {
      Print(">>>>  stopExpert clicked!");
      stopExpert = true;
    }
  }
}
