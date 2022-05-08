import React from 'react';
import PengineClient from './PengineClient';
import Board from './Board';



/**
 * Dimensiones de las grillas que se generen
 */

const anchoGrilla = 14;
const altoGrilla = 14;

/**
 * List of colors.
 */

const colors = ["r", "v", "p", "g", "b", "y"];  // red, violet, pink, green, blue, yellow

//const colors = ["r", "v", "p", "g", "b", "y", "w", "lb", "o"];  // red, violet, pink, green, blue, yellow, white, lightblue, orange

/**
 * Returns the CSS representation of the received color.
 */

export function colorToCss(color) {
  switch (color) {
    case "r": return "red";
    case "v": return "violet";
    case "p": return "pink";
    case "g": return "green";
    case "b": return "blue";
    case "y": return "yellow";
    case "w": return "white";
    case "lb": return "lightblue";
    case "o": return "orange";
    default: return "red";
  }
}
class Game extends React.Component {

  pengine;

  constructor(props) {
    super(props);
    this.state = {
      turns: 0,
      grid: null,
      cantCeldasCapturadas:0,
      complete: false,  // true if game is complete, false otherwise
      waiting: false,
      origen: [0, 0],
      historialMovimientos: []
    };
    this.handleClick = this.handleClick.bind(this);
    this.handlePengineCreate = this.handlePengineCreate.bind(this);
    this.pengine = new PengineClient(this.handlePengineCreate);
  }

  handlePengineCreate() {
    const queryS = 'init(Grid)';
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        this.setState({
          grid: response['Grid']
        });
        console.log("grid: " + JSON.stringify(this.state.grid));
      }
    });
  }

  handleClickOrigen(x, y) {
    console.log("Celda Clickeada: [" + x + ", " + y + "]");
    if (this.state.turns === 0) {
      this.setState({
        origen: [x, y]
      });
    }
  }

  elegirElementoRandom(arreglo){ 
    let cantidadDeElementos = arreglo.length;
    let numeroAleatorio = Math.floor(Math.random()*cantidadDeElementos); 
    let elementoAleatorio = arreglo[numeroAleatorio]; 
    return elementoAleatorio; 
  } 
 
  crearTableroAleatorio(anchoTablero, altoTablero, arreglo){ 
    console.log("Creando tablero");
    let tablero = [];
    for (let i = 0; i < altoTablero; i++){ 
        let fila = [] 
        for (let j = 0; j < anchoTablero; j++){
          let elem = this.elegirElementoRandom(arreglo);
          fila.push(elem);
        } 
        console.log("fila " + i + ": " + fila);
        tablero.push(fila); 
    }
    return tablero; 
  }

  reiniciarJuego() {
    console.log("reiniciando juego");
    let grillaNueva = this.crearTableroAleatorio(anchoGrilla, altoGrilla, colors);
    console.log(grillaNueva);
    this.setState({
      turns: 0,
      grid: grillaNueva,
      cantCeldasCapturadas:0,
      complete: false,  // true if game is complete, false otherwise
      waiting: false,
      origen: [0, 0],
      historialMovimientos: []
    });
  }

  handleClick(color) {
    // No action on click if game is complete or we are waiting.
    if (this.state.complete || this.state.waiting) {
      return;
    }
    // Build Prolog query to apply the color flick.
    // The query will be like:
    // flick([[y,g,b,g,v,y,p,v,b,p,v,p,v,r],
    //        [r,r,p,p,g,v,v,r,r,b,g,v,p,r],
    //        [b,v,g,y,b,g,r,g,p,g,p,r,y,y],
    //        [r,p,y,y,y,p,y,g,r,g,y,v,y,p],
    //        [y,p,y,v,y,g,g,v,r,b,v,y,r,g],
    //        [r,b,v,g,b,r,y,p,b,p,y,r,y,y],
    //        [p,g,v,y,y,r,b,r,v,r,v,y,p,y],
    //        [b,y,v,g,r,v,r,g,b,y,b,y,p,g],
    //        [r,b,b,v,g,v,p,y,r,v,r,y,p,g],
    //        [v,b,g,v,v,r,g,y,b,b,b,b,r,y],
    //        [v,v,b,r,p,b,g,g,p,p,b,y,v,p],
    //        [r,p,g,y,v,y,r,b,v,r,b,y,r,v],
    //        [r,b,b,v,p,y,p,r,b,g,p,y,b,r],
    //        [v,g,p,b,v,v,g,g,g,b,v,g,g,g]], [Xorig, Yorig], r, Grid)
    const gridS = JSON.stringify(this.state.grid).replaceAll('"', "");
    const origS = JSON.stringify(this.state.origen);
    const queryS = "flick(" + gridS + ", " + origS + ", " + color + ", Grid, CantidadCeldasCapturadas, Estado)";
    this.setState({
      waiting: true
    });
    this.pengine.query(queryS, (success, response) => {
      if (success) {
        const historialMovimientosAux = this.state.historialMovimientos.slice();
        historialMovimientosAux.push(color);
        this.setState({
          grid: response['Grid'],
          complete: response['Estado'],
          cantCeldasCapturadas: response['CantidadCeldasCapturadas'],
          turns: this.state.turns + 1,
          waiting: false,
          historialMovimientos: historialMovimientosAux
        });
        console.log("completo: " + this.state.complete);
        console.log("grilla: " + response["Grid"]);
        console.log("CeldasCapturadas: " + this.state.cantCeldasCapturadas);
      } else {
        // Prolog query will fail when the clicked color coincides with that in the top left cell.
        this.setState({
          waiting: false
        });
      }
    });
  }

  render() {
    if (this.state.grid === null) {
      return null;
    }
    return (
      <div>
        <div className="game">
          <div className="leftPanel">
            <div className="buttonsPanel">
              {colors.map(color =>
                <button
                  className="colorBtn"
                  style={{ backgroundColor: colorToCss(color) }}
                  onClick={() => this.handleClick(color)}
                  key={color}
                />)}
            </div>
            <div className="turnsPanel">
              <div className="turnsLab">Turnos</div>
              <div className="turnsNum">{this.state.turns}</div>
            </div>
            <div className="TextoLateral">
              <p>Cantidad de celdas capturadas: {this.state.cantCeldasCapturadas}</p>
            </div>
            <div className="TextoLateral">
              <p>Estado del juego: {this.state.complete ? "Terminado" : "En ejecucion"}</p>
              <button onClick={() => this.reiniciarJuego()}>Reiniciar Juego</button>
            </div>
            <div className="TextoLateral">
                <p> Antes de Comenzar, haga click en la celda que desea usar como origen.</p>
                <p>CELDA ORIGEN: {JSON.stringify(this.state.origen)}</p>
            </div>
          </div>
          <Board 
            grid={this.state.grid}
            onClick={(x, y) => this.handleClickOrigen(x, y)}
            ancho={anchoGrilla}
            alto={altoGrilla}
          />
          
        </div>
        <div className="HistorialJugadas">
          <p>Historial de jugadas:</p>{this.state.historialMovimientos.map((color, i) =>
                  <button
                    className="colorBtn"
                    style={{ backgroundColor: colorToCss(color), width: 540/anchoGrilla + "px", height: 500/altoGrilla + "px"}}
                    key={i}
                  />)}
        </div>
      </div>
    );
  }
}

export default Game;