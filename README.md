# IC Design 23Fall HW2
##### author : B10901176 蔡弘祥

#### Before Running
```shell
source ./tool.sh
```

#### How To Run
```shell
cd src
./check.sh
./sim.sh
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

1. check straight and flush
    - 8 straight flush
    - 4 straight
    - 5 flush
    - 0 high card
2. check rank 
    - 7 four of a kind
    - 6 full house
    - 3 three of a kind
    - 2 two pair
    - 1 one pair
    - 0 high card

* avoid CASCADING LOGIC GATES
* Is sorting necessary ?