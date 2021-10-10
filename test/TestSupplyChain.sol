pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    // buyItem

    // test for failure if user does not send enough funds
    function testFailureNotEnoughFunds() public {
        SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());
        bool r;

        sc.addItem("book", 1000);
        (r, ) = address(this).call.value(10 wei)(abi.encodePacked(sc.buyItem.selector, uint(0)));
        Assert.isFalse(r, "test for failure if user does not send enough funds");
    }
    // test for purchasing an item that is not for Sale
    function testFailureNotForSale() public {
        SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());
        bool r;

        sc.addItem("book", 1000);
        address(this).call.value(10000 wei)(abi.encodePacked(sc.buyItem.selector, uint(0)));
        (r, ) = address(this).call.value(10000 wei)(abi.encodePacked(sc.buyItem.selector, uint(0)));
        Assert.isFalse(r, "test for purchasing an item that is not for Sale");
    }

    // shipItem

    // test for calls that are made by not the seller
    function testFailureShipNotSeller() public {
        SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());
        bool r;

        sc.addItem("book", 1000);
        address(this).call.value(10000 wei)(abi.encodePacked(sc.buyItem.selector, uint(0)));
        (r, ) = address(0).call.value(10000 wei)(abi.encodePacked(sc.shipItem.selector, uint(0)));
        Assert.isFalse(r, "test for calls that are made by not the seller");
    }
    // test for trying to ship an item that is not marked Sold
    function testFailureShipNotSold() public {
        SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());
        bool r;

        sc.addItem("book", 1000);
        (r, ) = address(this).call.value(10000 wei)(abi.encodePacked(sc.shipItem.selector, uint(0)));
        Assert.isFalse(r, "test for trying to ship an item that is not marked Sold");
    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    function testFailureReceiveNotBuyer() public {
        SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());
        bool r;
        address payable seller = address(uint160(address(this)));
        address payable buyer = address(uint160(address(this)));
        address payable buyerFake;

        sc.addItem("book", 1000);
        buyer.call.value(10000 wei)(abi.encodePacked(sc.buyItem.selector, uint(0)));
        seller.call.value(10000 wei)(abi.encodePacked(sc.shipItem.selector, uint(0)));
        (r, ) = buyerFake.call.value(10000 wei)(abi.encodePacked(sc.receiveItem.selector, uint(0)));
        Assert.isFalse(r, "test calling the function from an address that is not the buyer");
    }
    // test calling the function on an item not marked Shipped
    function testFailureReceiveNotShipped() public {
        SupplyChain sc = SupplyChain(DeployedAddresses.SupplyChain());
        bool r;

        sc.addItem("book", 1000);
        (r, ) = address(this).call.value(10000 wei)(abi.encodePacked(sc.receiveItem.selector, uint(0)));
        Assert.isFalse(r, "test calling the function on an item not marked Shipped");
    }

}
