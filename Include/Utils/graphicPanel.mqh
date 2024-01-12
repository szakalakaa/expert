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
  CLabel isMainAuxOrderLabel;
  CLabel isSecondReverseOrderLabel;

  CLabel timeBlockadeCrossLabel;
  CLabel timeBlockadeMainLabel;


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


  // isCrossOrder
  if (global.isCrossOrder)
    isCrossOrderLabel.Color(clrLightSkyBlue);
  else if (!global.isCrossOrder)
    isCrossOrderLabel.Color(clrLightCoral);

  if (global.timeBlockadeCross)
  {
    timeBlockadeCrossLabel.Color(clrLightSkyBlue);
    timeBlockadeCrossLabel.Text("timeBlockadeCross: " + (string)(global.crossRemainMinutes));
    isCrossOrderLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
  }
  else
  {
    timeBlockadeCrossLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
    timeBlockadeCrossLabel.Text("");
  }
  // isMainAuxOrder
  if (global.isMainAuxOrder)
    isMainAuxOrderLabel.Color(clrLightSkyBlue);
  else if (!global.isMainAuxOrder)
    isMainAuxOrderLabel.Color(clrLightCoral);

  // isMainOrder
  if (global.isMainOrder)
    isMainOrderLabel.Color(clrLightSkyBlue);
  else if (!global.isMainOrder)
    isMainOrderLabel.Color(clrLightCoral);

  if (global.timeBlockadeMain)
  {
    timeBlockadeMainLabel.Color(clrLightSkyBlue);
    timeBlockadeMainLabel.Text("timeBlockadeMain: " + (string)(global.mainRemainMinutes));
    isMainOrderLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
  }
  else
  {
    timeBlockadeMainLabel.Color(CONTROLS_DIALOG_COLOR_CLIENT_BG);
    timeBlockadeMainLabel.Text("");
  }

  //isSecondReverseOrder
  
 if (global.isSecondReverseOrder)
    isSecondReverseOrderLabel.Color(clrLightSkyBlue);
  else if (!global.isSecondReverseOrder)
    isSecondReverseOrderLabel.Color(clrLightCoral);
  //
  type_positionLabel.Text((string)type_position);
  lotsInPositionLabel.Text((string)global.lotsInPosition);
  positionOpenPriceLabel.Text((string)global.positionOpenPrice);

  PositionSelect(_Symbol);
  valueLabel.Text("value: " + (string)(NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * global.last, 0)) + " USD");

  // UPPR LEFT CORNER VALUR
  if (global.currentBalance > 100)
    currentBalanceLabel.Color(clrLightSkyBlue);
  else
    currentBalanceLabel.Color(clrLightCoral);
  currentBalanceLabel.Text((string)initial.testBool);

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
  currentBalanceLabel.Text((string)global.currentBalance);
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


  int posY = 100;
  type_positionLabel.Create(NULL, "type_positionLabel", 0, 10, posY, 1, 1);
  type_positionLabel.Text((string)type_position);
  type_positionLabel.Color(clrWheat);
  type_positionLabel.FontSize(InpPanelFontSize);
  this.Add(type_positionLabel);

  lotsInPositionLabel.Create(NULL, "lotsInPositionLabel", 0, 120, posY, 1, 1);
  lotsInPositionLabel.Text((string)global.lotsInPosition);
  lotsInPositionLabel.Color(clrWheat);
  lotsInPositionLabel.FontSize(InpPanelFontSize);
  this.Add(lotsInPositionLabel);

  positionOpenPriceLabel.Create(NULL, "positionOpenPriceLabel", 0, 180, posY, 1, 1);
  positionOpenPriceLabel.Text((string)global.positionOpenPrice);
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
  timeBlockadeCrossLabel.Color(clrWheat);
  timeBlockadeCrossLabel.FontSize(InpPanelFontSize);
  this.Add(timeBlockadeCrossLabel);

  isMainAuxOrderLabel.Create(NULL, "isMainAuxOrderLabel", 0, orderX, orderY + 20, 1, 1);
  isMainAuxOrderLabel.Text("isMainAuxOrder");
  isMainAuxOrderLabel.Color(clrWheat);
  isMainAuxOrderLabel.FontSize(InpPanelFontSize);
  this.Add(isMainAuxOrderLabel);

  isMainOrderLabel.Create(NULL, "isMainOrderLabel", 0, orderX, +orderY + 40, 1, 1);
  isMainOrderLabel.Text("isMainOrder");
  isMainOrderLabel.Color(clrWheat);
  isMainOrderLabel.FontSize(InpPanelFontSize);
  this.Add(isMainOrderLabel);

  isSecondReverseOrderLabel.Create(NULL, "isSecondReverseOrderLabel", 0, orderX, +orderY + 60, 1, 1);
  isSecondReverseOrderLabel.Text("isSecondReverseOrder");
  isSecondReverseOrderLabel.Color(clrWheat);
  isSecondReverseOrderLabel.FontSize(InpPanelFontSize);
  this.Add(isSecondReverseOrderLabel);

  timeBlockadeMainLabel.Create(NULL, "timeBlockadeMainLabel", 0, orderX, orderY + 40, 1, 1);
  timeBlockadeMainLabel.Color(clrWheat);
  timeBlockadeMainLabel.FontSize(InpPanelFontSize);
  this.Add(timeBlockadeMainLabel);

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
  valueLabel.Text("value: " + (string)(NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * global.last, 0)) + " USD");
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
  datetime currentTimer = TimeCurrent();

  if (id == CHARTEVENT_OBJECT_CLICK)
  {

    if (sparam == "resetCrossTimer")
    {
      Print(">>>>  resetCrossTimer clicked!");
      global.crossRemainMinutes = 0;
      global.timeBlockadeCross = false;
      createObject(currentTimer, global.last, 231, clrOrange, "73");
    }

    if (sparam == "resetMainTimer")
    {
      Print(">>>>  resetMainTimer clicked!");
      global.mainRemainMinutes = 0;
      global.timeBlockadeMain = false;
      createObject(currentTimer, global.last, 231, clrOrange, "73");
    }

    if (sparam == "setCrossTimer")
    {
      Print(">>>>  setCrossTimer clicked!");
      global.crossRemainMinutes = 50;
      global.timeBlockadeCross = true;
      createObject(currentTimer, global.last, 232, clrDarkGray, "2");
    }

    if (sparam == "setMainTimer")
    {
      Print(">>>>  setMainTimer clicked!");
      global.mainRemainMinutes = 50;
      global.timeBlockadeMain = true;
      createObject(currentTimer, global.last, 232, clrDarkGray, "2");
    }
    if (sparam == "startExpertButton")
    {
      Print(">>>>  startExpert clicked!");
      global.stopExpert = false;
    }
    if (sparam == "stopExpertButton")
    {
      Print(">>>>  stopExpert clicked!");
      global.stopExpert = true;
    }
  }
}
