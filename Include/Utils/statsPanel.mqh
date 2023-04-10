
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
#define CONTROLS_DIALOG_COLOR_CLIENT_BG C clrNavy

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                             |
//+------------------------------------------------------------------+
// input group "====Panel Inputs====";
static int PanelWidth = 300;               // width in pixel
static int PanelHeight = 400;              // height in pixel
static int PanelFontSize = 10;             // width in pixel
static int PanelTextColor = clrWhiteSmoke; // text clr

//+------------------------------------------------------------------+
//| Class CStatsPanel                                                                  |
//+------------------------------------------------------------------+
class CStatsPanel : public CAppDialog
{
private:
  // private variables

  // labels

  CLabel main_header;
  CLabel highest24Label;
  CLabel lowest24Label;
  CLabel spread24Label;

  // private methods
  bool CheckInputs();
  bool CreatePanel();

public:
  void CStatsPanel();
  void ~CStatsPanel();
  bool Oninit();
  void Update();

  // chart event handler lparam ->as a refference
  void PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
};

// constructor
void CStatsPanel::CStatsPanel(void) {}

// deconstructor
void CStatsPanel::~CStatsPanel(void) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStatsPanel::Oninit(void)
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

void CStatsPanel::Update(void)
{
  highest24Label.Text("highest24:      " + (string)stats.highest24);
  spread24Label.Text((string)stats.spread24);
  if (stats.lowest24 > 99990)
  {
    lowest24Label.Text("lowest24:       0.0");
  }
  else
    lowest24Label.Text("lowest24:       " + (string)stats.lowest24);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStatsPanel::CheckInputs(void)
{
  if (PanelWidth <= 0)
  {
    Print("Panel width <=0");
    return false;
  }
  if (PanelHeight <= 0)
  {
    Print("Panel height <=0");
    return false;
  }
  if (PanelFontSize <= 0)
  {
    Print("Panel font size <=0");
    return false;
  }

  return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStatsPanel::CreatePanel(void)
{
  // create dialog panel
  this.Create(NULL, "Statistics", 0, InpPanelWidth, 30, PanelWidth+InpPanelWidth, PanelHeight);

  main_header.Create(NULL, "main_header", 0, 10, 10, 1, 1);
  main_header.Text("Statistics:");
  main_header.Color(clrLime);
  main_header.FontSize(PanelFontSize);
  this.Add(main_header);

  highest24Label.Create(NULL, "highest24Label", 0, 10, 30, 1, 1);
  highest24Label.Text("highest24:      " + (string)stats.highest24);
  highest24Label.Color(clrWheat);
  highest24Label.FontSize(PanelFontSize);
  this.Add(highest24Label);

  spread24Label.Create(NULL, "spread24Label", 0, 10, 60, 1, 1);
  spread24Label.Text((string)stats.spread24);
  spread24Label.Color(clrWheat);
  spread24Label.FontSize(PanelFontSize + 6);
  this.Add(spread24Label);

  lowest24Label.Create(NULL, "lowest24Label", 0, 10, 100, 1, 1);
  if (stats.lowest24 > 99990)
  {
    lowest24Label.Text("lowest24:       0.0");
  }
  else
    lowest24Label.Text("lowest24:       " + (string)stats.lowest24);

  lowest24Label.Color(clrWheat);
  lowest24Label.FontSize(PanelFontSize);
  this.Add(lowest24Label);

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
void CStatsPanel::PanelChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
  // call chart event method of base class
  ChartEvent(id, lparam, dparam, sparam);
}
//+------------------------------------------------------------------+
