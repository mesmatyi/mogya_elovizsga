set ProductGroups;

param nRows;
param cashierCount;
param cashierLength;
param space{ProductGroups};

set Rows := 1..nRows;

var productPlace {Rows, ProductGroups} binary;
var length{Rows} >= 0;

var longestRow >= 0;

s.t. FillUpRowsWithProduct{p in ProductGroups}:
    sum{r in Rows} productPlace[r,p] = 1;

s.t. FitInProducts{r in Rows : r > cashierCount}:
    length[r] = sum{p in ProductGroups} productPlace[r,p]*space[p];

s.t. FitInProdctsWithCashierDesk{r in Rows : r <= cashierCount}:
    length[r] = sum{p in ProductGroups} productPlace[r,p]*space[p] + cashierLength;

s.t. getLongestRow{r in Rows}:
    longestRow >= length[r];

minimize BuildingLength: longestRow;

solve;

printf "%f\n",BuildingLength;