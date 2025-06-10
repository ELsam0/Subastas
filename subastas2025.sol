// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Subasta {
    // Dirección del dueño de la subasta
    address public dueno;

    // Dirección del mejor postor y su oferta
    address public mejorPostor;
    uint public mejorOferta;

    // Tiempo en que termina la subasta
    uint public finSubasta;

    // Estado de la subasta
    bool public finalizada;

    // Comisión del 2% para reembolsos
    uint public constanteComision = 2;

    // Lista de oferentes únicos
    address[] public oferentes;

    // Mapea cada dirección con el total depositado
    mapping(address => uint) public depositos;

    // Lista de ofertas por usuario (para reembolsos parciales)
    mapping(address => uint[]) public historialOfertas;

    // Eventos
    event NuevaOferta(address oferente, uint monto);
    event SubastaFinalizada(address ganador, uint monto);

    // Modificador: solo antes de que termine la subasta
    modifier soloAntesDelFinal() {
        require(block.timestamp < finSubasta, "La subasta ha finalizado");
        _;
    }

    // Modificador: solo después de que termine la subasta
    modifier soloDespuesDelFinal() {
        require(block.timestamp >= finSubasta, "La subasta aun esta activa");
        _;
    }

    // Modificador: solo el dueño puede ejecutar
    modifier soloDueno() {
        require(msg.sender == dueno, "Solo el dueno puede hacer esto");
        _;
    }

    // Constructor: define duración de la subasta (en minutos)
    constructor(uint _duracionMinutos) {
        dueno = msg.sender;
        finSubasta = block.timestamp + (_duracionMinutos * 1 minutes);
    }

    // Función para ofertar (enviar ETH)
    function ofertar() external payable soloAntesDelFinal {
        require(msg.value > 0, "Debes ofertar algo");

        uint nuevaOferta = depositos[msg.sender] + msg.value;
        uint aumentoMinimo = mejorOferta + (mejorOferta * 5) / 100;

        // Si es la primera oferta, cualquier monto es aceptado
        if (mejorOferta == 0 || nuevaOferta >= aumentoMinimo) {
            // Registrar el oferente si es nuevo
            if (depositos[msg.sender] == 0) {
                oferentes.push(msg.sender);
            }

            // Guardar el historial de esta nueva oferta
            historialOfertas[msg.sender].push(msg.value);

            // Actualizar depósito total
            depositos[msg.sender] = nuevaOferta;

            // Actualizar mejor oferta
            mejorOferta = nuevaOferta;
            mejorPostor = msg.sender;

            // Si faltan 10 minutos o menos, extender 10 minutos
            if (finSubasta - block.timestamp <= 10 minutes) {
                finSubasta = block.timestamp + 10 minutes;
            }

            emit NuevaOferta(msg.sender, nuevaOferta);
        } else {
            revert("Debes superar la mejor oferta en al menos 5%");
        }
    }

    // Ver al ganador y su oferta
    function mostrarGanador() external view soloDespuesDelFinal returns (address, uint) {
        return (mejorPostor, mejorOferta);
    }

    // Ver todos los oferentes y sus depósitos
    function mostrarOfertas() external view returns (address[] memory, uint[] memory) {
        uint[] memory montos = new uint[](oferentes.length);

        for (uint i = 0; i < oferentes.length; i++) {
            montos[i] = depositos[oferentes[i]];
        }

        return (oferentes, montos);
    }

    // Finaliza la subasta
    function finalizarSubasta() external soloDueno soloDespuesDelFinal {
        require(!finalizada, "Ya finalizo");
        finalizada = true;

        emit SubastaFinalizada(mejorPostor, mejorOferta);
    }

    // Reembolsar a los que no ganaron (con 2% de descuento)
    function devolverDepositos() external soloDespuesDelFinal {
        require(finalizada, "La subasta no fue finalizada aun");

        for (uint i = 0; i < oferentes.length; i++) {
            address user = oferentes[i];
            if (user != mejorPostor && depositos[user] > 0) {
                uint total = depositos[user];
                uint comision = (total * constanteComision) / 100;
                uint aDevolver = total - comision;

                depositos[user] = 0;

                payable(user).transfer(aDevolver);
            }
        }
    }

    // Permitir retirar el excedente de una oferta anterior
    function reembolsoParcial() external soloAntesDelFinal {
        uint[] storage historial = historialOfertas[msg.sender];
        require(historial.length > 1, "No hay excedentes para retirar");

        uint totalExceso = 0;

        // Eliminar todas las ofertas excepto la última
        while (historial.length > 1) {
            totalExceso += historial[0];
            for (uint i = 0; i < historial.length - 1; i++) {
                historial[i] = historial[i + 1];
            }
            historial.pop();
        }

        // Restar el exceso del depósito
        depositos[msg.sender] -= totalExceso;

        payable(msg.sender).transfer(totalExceso);
    }
}
