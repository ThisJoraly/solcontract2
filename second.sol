pragma solidity ^0.8.0;

contract PropertyManager {
    address public manager;
    bool public isOperational;
    uint256 public accountBalance;
    uint256 public estateCount;
    uint256 public advertisementCount;

    struct Estate {
        address owner;
        uint256 estateId;
        bool isActive;
    }

    struct Advertisement {
        address owner;
        uint256 estateId;
        uint256 adId;
        bool isActive;
        uint256 salePrice;
    }

    mapping(uint256 => Estate) public estates;
    mapping(uint256 => Advertisement) public advertisements;

    event EstateCreated(
        address indexed owner,
        uint256 estateId,
        uint256 registrationDate,
        string propertyCategory
    );
    event AdCreated(
        address indexed owner,
        uint256 estateId,
        uint256 adId,
        uint256 publicationDate,
        uint256 salePrice
    );
    event EstateUpdated(
        address indexed owner,
        uint256 estateId,
        uint256 changeDate,
        bool newStatus
    );
    event AdUpdated(
        address indexed owner,
        uint256 estateId,
        uint256 adId,
        uint256 changeDate,
        bool newStatus
    );
    event EstatePurchased(
        address indexed owner,
        address buyer,
        uint256 adId,
        uint256 estateId,
        bool adStatus,
        uint256 saleDate,
        uint256 salePrice
    );
    event FundsSent(
        address indexed receiver,
        uint256 amount,
        uint256 withdrawalDate
    );

    constructor() {
        manager = msg.sender;
        isOperational = true;
        accountBalance = 0;
        estateCount = 1;
        advertisementCount = 1;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            unicode"Эта функция предназначена только для менеджеров"
        );
        _;
    }

    modifier onlyOperational() {
        require(
            isOperational == true,
            unicode"Менеджер по недвижимости не работает"
        );
        _;
    }

    function registerEstate() public onlyManager {
        estates[estateCount] = Estate(manager, estateCount, true);
        emit EstateCreated(
            manager,
            estateCount,
            block.timestamp,
            unicode"Жилой"
        );
        estateCount++;
    }

    function publishAdvertisement(uint256 _estateId, uint256 _salePrice)
        public
        onlyManager
        onlyOperational
    {
        require(
            estates[_estateId].owner == manager &&
                estates[_estateId].isActive == true,
            unicode"Вы можете опубликовать рекламу только на свою активную недвижимость."
        );
        advertisements[advertisementCount] = Advertisement(
            manager,
            _estateId,
            advertisementCount,
            true,
            _salePrice
        );
        emit AdCreated(
            manager,
            _estateId,
            advertisementCount,
            block.timestamp,
            _salePrice
        );
        advertisementCount++;
    }

    function deactivateEstate(uint256 _estateId) public onlyManager {
        require(
            estates[_estateId].owner == manager,
            "You can only deactivate your own estate"
        );
        estates[_estateId].isActive = false;
        emit EstateUpdated(manager, _estateId, block.timestamp, false);

        if (advertisements[_estateId].isActive == true) {
            advertisements[_estateId].isActive = false;
            emit AdUpdated(
                manager,
                _estateId,
                advertisements[_estateId].adId,
                block.timestamp,
                false
            );
        }
    }

    function deactivateAdvertisement(uint256 _estateId)
        public
        onlyManager
        onlyOperational
    {
        require(
            estates[_estateId].owner == manager &&
                estates[_estateId].isActive == true,
            unicode"Вы можете деактивировать рекламу только для вашей активной недвижимости."
        );
        advertisements[_estateId].isActive = false;
        emit AdUpdated(
            manager,
            _estateId,
            advertisements[_estateId].adId,
            block.timestamp,
            false
        );
    }

    function withdrawFunds(uint256 _amount) public onlyManager {
        require(_amount <= accountBalance, "Insufficient funds");
        accountBalance -= _amount;
        payable(msg.sender).transfer(_amount);
        emit FundsSent(msg.sender, _amount, block.timestamp);
    }

    function getBalance() public view returns (uint256) {
        return accountBalance;
    }

    function getEstate(uint256 _estateId) public view returns (Estate memory) {
        return estates[_estateId];
    }

    function getAdvertisement(uint256 _adId) public view returns (Advertisement memory) {
        return advertisements[_adId];
    }
}
