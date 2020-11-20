set ProductGroups;
set CustomerGroups;

set MustBeSeparated within {ProductGroups,ProductGroups};
set MustBeTogether within {ProductGroups,ProductGroups};

param nRows;
param cashierCount;
param cashierLength;
param maxRowLength;

param averagePrice{ProductGroups};
param space{ProductGroups};

param count{CustomerGroups};
param probabilityToBuy{CustomerGroups};

param buys{CustomerGroups,ProductGroups} binary;


set Rows := 1..nRows;

var productPlace {Rows, ProductGroups} binary;
var length{Rows} >= 0;

var seesProduct{CustomerGroups,ProductGroups} binary;

var buysUnwantedStuff{CustomerGroups,ProductGroups} binary;

var longestRow >= 0;

s.t. FillUpRowsWithProduct{p in ProductGroups}:
    sum{r in Rows} productPlace[r,p] = 1;

s.t. MaximumRowLength:
    longestRow <= maxRowLength;

s.t. getLongestRow{r in Rows}:
    longestRow >= length[r];

s.t. SpotWantedProduct{r in Rows,c in CustomerGroups,p in ProductGroups : buys[c,p] == 1}:
    seesProduct[c,p] = 1;

s.t. NotSpotWantedProduct{r in Rows,c in CustomerGroups,p in ProductGroups : buys[c,p] == 0}:
    seesProduct[c,p] = 0;

s.t. mustBeInSameRowTheseProducts{r in Rows, (p1,p2) in MustBeTogether}:
	productPlace[r,p1] = productPlace[r,p2];

s.t. SomeProductsSouldntBeInTheSamePlace{r in Rows,(p1,p2) in MustBeTogether}:
    productPlace[r,p1] >= productPlace[r,p2] -1;

s.t. BuysTheUnwantedProduct{r in Rows,c in CustomerGroups,p in ProductGroups}:
    buysUnwantedStuff[c,p] = seesProduct[c,p];

s.t. FitInProducts{r in Rows : r > cashierCount}:
    length[r] = sum{p in ProductGroups} productPlace[r,p]*space[p];

s.t. FitInProdctsWithCashierDesk{r in Rows : r <= cashierCount}:
    length[r] = sum{p in ProductGroups} productPlace[r,p]*space[p] + cashierLength;


minimize ExtraProfit: sum{c in CustomerGroups, p in ProductGroups} buysUnwantedStuff[c,p]*(averagePrice[p]*probabilityToBuy[c]*count[c]);

solve;

printf "%f\n",ExtraProfit;