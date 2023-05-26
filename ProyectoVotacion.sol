//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ProyectoVotacion{

    struct Candidato {
        string nombre;
        string proyecto;
        string nacionalidad;
        uint votos;
        address wallet;
    }
    
    address public owner;
    bool public votacionIniciada;
    bool public votacionFinalizada;
    
    mapping(address => bool) public votantesAutorizados;
    mapping(address => bool) public votosEmitidos;
    mapping(uint => Candidato) public candidatos;
    uint public numCandidatos;
    uint public maxVotos;
    uint public ganador;
    
    constructor() {
        owner = msg.sender;
        numCandidatos = 0;
        maxVotos = 0;
        votacionIniciada = false;
        votacionFinalizada = false;
    }
    
    modifier soloOwner() {
        require(msg.sender == owner, "Solo el duenio del contrato puede realizar esta accion.");
        _;
    }
    
    modifier votacionNoIniciada() {
        require(!votacionIniciada, "La votacion ya ha sido iniciada.");
        _;
    }
    
    modifier votacionActiva() {
        require(votacionIniciada && !votacionFinalizada, "La votacion no esta activa.");
        _;
    }
    
    function iniciarVotacion() public soloOwner votacionNoIniciada {
        votacionIniciada = true;
    }
    
    function finalizarVotacion() public soloOwner votacionActiva {
        votacionFinalizada = true;
    }
    
    function registrarCandidato(string memory _nombre, string memory _proyecto, string memory _nacionalidad, address _wallet) public soloOwner votacionNoIniciada {
        uint idCandidato = numCandidatos;
        candidatos[idCandidato] = Candidato(_nombre, _proyecto, _nacionalidad, 0, _wallet);
        numCandidatos++;
    }
    
    function darDerechoAVoto(address _votante) public soloOwner votacionActiva {
        votantesAutorizados[_votante] = true;
    }
    
    function realizarVoto(uint _idCandidato) public votacionActiva {
        require(votantesAutorizados[msg.sender], "No tienes derecho a votar.");
        require(!votosEmitidos[msg.sender], "Ya has emitido tu voto.");
        require(_idCandidato < numCandidatos, "Candidato no valido.");
        
        votosEmitidos[msg.sender] = true;
        candidatos[_idCandidato].votos++;
        
        if (candidatos[_idCandidato].votos >= maxVotos) {
            maxVotos = candidatos[_idCandidato].votos;
            ganador = _idCandidato;
        }
    }
    
        function obtenerGanador() public view returns (string memory, address) {
    require(votacionFinalizada, "La votacion aun no ha finalizado.");
    Candidato memory ganadorCandidato = candidatos[ganador];
    return (ganadorCandidato.nombre, ganadorCandidato.wallet);
    }
}
