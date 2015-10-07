# T-FACE 2001-2109, 585 ppm CO2,
# heated +3.5 °C. For correct
# baseline conditions, run this schedule
# as an extension of sf20th.bin.
2001          Starting year
2109          Last year
soyface.100           Site file name
0             Labeling type
-1            Labeling year
-1.00         Microcosm
1             CO2 Systems
2000 2110
0             pH shift
-1             Soil warming
0             N input scalar option
0             OMAD scalar option
3             Climate scalar option
2009 2109
1             Initial system
SYBN          Initial crop
              Initial tree

Year Month Option
1             Block #   soyFACE soy-corn
2008          Last year
8             Repeats # years
2001          Output starting year
1             Output month
0.038         Output interval
F             Weather choice
sfdm01_11.wth
   1   115 CULT # 2001, soy
F
   1   143 CROP
SYBN
   1   143 PLTM
   1   143 CULT
C
   1   291 HARV
G
   1   291 LAST
   2    140 FERT # 2002, corn
N15.7
   2   150 CROP
C10
   2   150 PLTM
   2   150 CULT
C
   2   283 HARV
G
   2   283 LAST
   2   300 CULT
J
   3   115 CULT # 2003, soy
F
   3   147 CROP
SYBN
   3   147 PLTM
   3   147 CULT
C
   3   291 HARV
G
   3   291 LAST
   4   110 FERT # 2004, corn
N15.7
   4   120 CROP
C10
   4   120 PLTM
   4   120 CULT
C
   4   254 HARV
G
   4   254 LAST
   4   300 CULT
J
   5   115 CULT # 2005, soy
F
   5   145 CROP
SYBN
   5   145 PLTM
   5   145 CULT
C
   5   299 HARV
G
   5   299 LAST
   6   108 FERT # 2006, corn
N15.7
   6   118 CROP
C10
   6   118 PLTM
   6   118 CULT
C
   6   251 HARV
G
   6   251 LAST
   6   300 CULT
J
   7   115 CULT # 2007, soy
F
   7   142 CROP
SYBN
   7   142 PLTM
   7   142 CULT
C
   7   276 HARV
G
   7   276 LAST
   8   140 FERT # 2008, corn
N15.7
   8   150 CROP
C10
   8   150 PLTM
   8   150 CULT
C
   8   275 HARV
G
   8   275 LAST
   8   300 CULT
J
-999 -999 X

2             Block #   TFACE soy-corn
2109          Last year
2             Repeats # years
2009          Output starting year
1             Output month
0.038         Output interval
C             Weather choice
   1   115 CULT
F
   1   160 CROP
SYBN
   1   160 PLTM
   1   160 CULT
C
   1   293 HARV
G
   1   293 LAST
   2   109 FERT
N15.7
   2   119 CROP
C10
   2   119 PLTM
   2   119 CULT
C
   2   250 HARV
G
   2   250 LAST
   2   300 CULT
J
-999 -999 X
