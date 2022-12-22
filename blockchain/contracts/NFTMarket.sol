// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemSold;

  address owner;
  uint256 listingPrice = 0.025 ether;

  constructor() {
    owner = payable(msg.sender);
  }

  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  MarketItem[] public marketItems;

  event MarketItemCreated (
    MarketItem createdMarketItem
  );

  event MarketItemSold (
    MarketItem createdMarketItem
  );

  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

  function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
    require(price > 0, "Price must be at least 1 wei");
    require(msg.value == listingPrice, "Price must be equal to listing price");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    MarketItem memory marketItem = MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );

    marketItems.push(marketItem);

    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);


    emit MarketItemCreated(marketItem);
  }

  function buyMarketItem(uint256 itemId) public payable nonReentrant {
    MarketItem memory marketItem = findMarketItemById(itemId);

    require(msg.value == marketItem.price, "Please submit the asking price in order to complete the purchase");

    marketItem.seller.transfer(msg.value);
    IERC721(marketItem.nftContract).transferFrom(address(this), msg.sender, marketItem.tokenId);

    marketItem.owner = payable(msg.sender);
    marketItem.sold = true;
    _itemSold.increment();

    payable(owner).transfer(listingPrice);

    emit MarketItemSold(marketItem);
  }

  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint marketItemsAmount = _itemIds.current();
    uint soldMarketItemsAmount = _itemSold.current();
    uint unsoldMarketItemsAmount = marketItemsAmount - soldMarketItemsAmount;
    MarketItem[] memory items = new MarketItem[](unsoldMarketItemsAmount);

    for (uint i = 0; i < marketItemsAmount; i++) {
      MarketItem storage currentMarketItem = marketItems[i];
      
      bool isUnsoldMarketItem = currentMarketItem.owner == address(0);

      if (isUnsoldMarketItem) {
        items[items.length] = currentMarketItem;
      }
    }

    return marketItems;
  }

  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    return findItemsByAddressCriteria(true);
  }

  function fetchMyItemsToSell() public view returns (MarketItem[] memory) {
    return findItemsByAddressCriteria(false);
  }
  
  function findItemsByAddressCriteria(bool isOwnerCriteria) private view returns (MarketItem[] memory) {
    uint itemsAmount = 0;

    for (uint i = 0; i < marketItems.length; i++) {
      bool isFitCriteria = false;

      if (isOwnerCriteria) {
        bool isNFTBelongsToCurrentSender = marketItems[i].owner == msg.sender;
        isFitCriteria = isNFTBelongsToCurrentSender;
      }  else {
        bool isNFTPutOnSellByCurrentSender = marketItems[i].seller == msg.sender;
        isFitCriteria = isNFTPutOnSellByCurrentSender;   
      }

      if (isFitCriteria) {
        itemsAmount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemsAmount);

    for (uint i = 0; i < marketItems.length; i++) {
      MarketItem memory currentItem;

      if (isOwnerCriteria) {
        bool isNFTBelongsToCurrentSender = currentItem.owner == msg.sender;

        if (isNFTBelongsToCurrentSender) {
          items[items.length] = currentItem;
        }
      } else {
         bool isNFTPutOnSellByCurrentSender = currentItem.seller == msg.sender;

        if (isNFTPutOnSellByCurrentSender) {
          items[items.length] = currentItem;
        }
      }
    }

    return items;
  }

  function findMarketItemById(uint id) private view returns (MarketItem memory) {
    MarketItem memory foundMarketItem;

    for (uint i = 0; i < _itemIds.current(); i++) {
      MarketItem memory currentMarketItem = marketItems[i];

      if (currentMarketItem.itemId == id) {
        foundMarketItem = currentMarketItem;
        break;
      }
    }

    return foundMarketItem;
  }
  
}