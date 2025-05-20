// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProductManager {
    struct Product {
        uint id;
        address owner;
        string title;
        string description;
        uint stock;
        uint priceInWei;
        string currency;
        uint timestamp;
        bool exists;
    }

    uint public productCount = 0;
    mapping(uint => Product) public products;

    event ProductCreated(uint id, address indexed owner);
    event ProductUpdated(uint id);
    event ProductDeleted(uint id);

    modifier onlyOwner(uint _id) {
        require(products[_id].exists, "Product does not exist");
        require(products[_id].owner == msg.sender, "Not product owner");
        _;
    }

    function createProduct(
        string memory _title,
        string memory _description,
        uint _stock,
        uint _priceInWei,
        string memory _currency
    ) public {
        productCount++;
        products[productCount] = Product({
            id: productCount,
            owner: msg.sender,
            title: _title,
            description: _description,
            stock: _stock,
            priceInWei: _priceInWei,
            currency: _currency,
            timestamp: block.timestamp,
            exists: true
        });

        emit ProductCreated(productCount, msg.sender);
    }

    function updateProduct(
        uint _id,
        string memory _title,
        string memory _description,
        uint _stock,
        uint _priceInWei,
        string memory _currency
    ) public onlyOwner(_id) {
        Product storage p = products[_id];
        p.title = _title;
        p.description = _description;
        p.stock = _stock;
        p.priceInWei = _priceInWei;
        p.currency = _currency;
        p.timestamp = block.timestamp;

        emit ProductUpdated(_id);
    }

    function deleteProduct(uint _id) public onlyOwner(_id) {
        delete products[_id];
        emit ProductDeleted(_id);
    }

    function getProduct(uint _id) public view returns (
        uint,
        address,
        string memory,
        string memory,
        uint,
        uint,
        string memory,
        uint
    ) {
        Product memory p = products[_id];
        require(p.exists, "Product does not exist");
        return (
            p.id,
            p.owner,
            p.title,
            p.description,
            p.stock,
            p.priceInWei,
            p.currency,
            p.timestamp
        );
    }

    function getMyProducts() public view returns (Product[] memory) {
        uint count = 0;
        for (uint i = 1; i <= productCount; i++) {
            if (products[i].owner == msg.sender && products[i].exists) {
                count++;
            }
        }

        Product[] memory myProducts = new Product[](count);
        uint j = 0;
        for (uint i = 1; i <= productCount; i++) {
            if (products[i].owner == msg.sender && products[i].exists) {
                myProducts[j] = products[i];
                j++;
            }
        }

        return myProducts;
    }
}
