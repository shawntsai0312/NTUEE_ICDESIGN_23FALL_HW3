# IC Design 23Fall HW3
##### author : B10901176 蔡弘祥

#### Before Running
```shell
source ./tool.sh
```

#### How To Run
```shell
cd src
./check.sh
./delay.sh
```

#### Cases
|number  |cases          |
|--------|---------------|
|0       |high card      |
|1       |one pair       |
|2       |two pair       |
|3       |three of a kind|
|4       |straight       |
|5       |flush          |
|6       |full house     |
|7       |four of a kind |
|8       |straight flush |

* Ace cannot be in the middle of a straight or a straight flush
* degrade into a high card or a flush

* flush checker
  * the first two bits of all five cards should be the same
* straight checker
  * directly detect all 10 cases
  * detect if a certain rank exist among all of the cards
* four of a kind checker
* full house checker
* three of a kind checker
* two pairs checker
* one pair checker
