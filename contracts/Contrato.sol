// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InverRealToken is ERC20 {

    // Dirección del propietario del contrato
    address public owner;

    // Dirección que gestionará la distribución de dividendos
    address public dividendManager;

    // Evento para registrar cambios de propietario
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Constructor para inicializar el token con nombre, símbolo y cantidad total de tokens
    constructor() ERC20("InverRealToken", "IRT") {
        // Establecer al creador del contrato como el propietario inicial
        owner = msg.sender;
        _mint(msg.sender, 1000000 * 10 ** decimals());  // 1,000,000 IRT
    }

    // Modificador para asegurarse de que solo el propietario pueda ejecutar ciertas funciones
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puede realizar esta accion");
        _;
    }

    // Modificador para asegurarse de que solo el dividendManager pueda ejecutar ciertas funciones
    modifier onlyDividendManager() {
        require(msg.sender == dividendManager, "Solo el dividendManager puede realizar esta accion");
        _;
    }

    // Función para transferir la propiedad del contrato a otro usuario
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Nuevo propietario no puede ser la direccion 0");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Función para establecer la dirección de dividendManager (quien distribuye los dividendos)
    function setDividendManager(address _dividendManager) external onlyOwner {
        dividendManager = _dividendManager;
    }

    // Función para distribuir dividendos de forma automática
    function distributeDividends(uint256 totalIncome) external onlyDividendManager {
        uint256 totalSupply = totalSupply();  // Obtener el total de tokens emitidos
        uint256 dividendPerToken = totalIncome / totalSupply;  // Dividendo por cada token

        // Distribuir dividendos proporcionalmente a cada titular de tokens
        for (uint256 i = 0; i < totalSupply; i++) {
            address account = address(uint160(i));  // Esto es solo ilustrativo, no es correcto en Solidity
            uint256 dividendAmount = balanceOf(account) * dividendPerToken;
            _mint(account, dividendAmount);  // Emitir nuevos tokens como dividendos
        }
    }

    // Función para permitir la recompra y quema de tokens
    function buyBackAndBurn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);  // El propietario puede comprar y quemar tokens
    }

    // Función para permitir la transferencia de tokens (como ERC-20 estándar)
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
}
