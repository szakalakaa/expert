<chart>
id=12345
symbol=BTCUSDT
period_type=0
period_size=15
digits=1
tick_size=0.500000
position_time=0
scale_fix=0
scale_fixed_min=17667.000000
scale_fixed_max=18375.500000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=32
mode=1
fore=0
grid=0
volume=0
scroll=1
shift=1
shift_size=10.546379
fixed_pos=0.000000
ohlc=1
bidline=0
askline=0
lastline=1
days=0
descriptions=0
tradelines=1
window_left=0
window_top=0
window_right=0
window_bottom=0
window_type=1
background_color=0
foreground_color=16777215
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=10061943
bidline_color=10061943
askline_color=255
lastline_color=49152
stops_color=255
windows_total=1

<window>
height=100.000000
objects=0

<indicator>
name=Main
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\tma_indikator.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=536872004
fixed_height=-1

<graph>
name=Centered TMA
draw=10
style=0
width=2
color=16436871,13353215
</graph>

<graph>
name=Centered TMA upper band
draw=1
style=2
width=1
color=16436871
</graph>

<graph>
name=Centered TMA lower band
draw=1
style=2
width=1
color=13353215
</graph>

<graph>
name=Rebound down
draw=3
style=0
width=2
arrow=226
color=13353215
</graph>

<graph>
name=Rebound up
draw=3
style=0
width=2
arrow=225
color=16436871
</graph>

<graph>
name=Centered TMA angle caution
draw=3
style=0
width=3
arrow=251
color=55295
</graph>
<inputs>
HalfLength=12
Price=0
AtrPeriod=120
AtrMultiplier=0.5
TMAangle=4
</inputs>
</indicator>
</window>
</chart>