import React from 'react';
import Square from './Square';

class Board extends React.Component {
    render() {
        return (
            <div className="board" style = {
                    {
                        "grid-template-columns": "repeat(" + this.props.grid[0].length + ", " + 540/(this.props.grid[0].length) + "px)",
                        "grid-template-rows": "repeat(" + this.props.grid.length + ",  " + 540/this.props.grid.length + "px)"
                    }
                }
            > 
                {this.props.grid.map((row, i) =>
                    row.map((cell, j) =>
                        <Square
                            value={cell}
                            key={i + "." + j}
                            onClick = {(x, y) => this.props.onClick(x, y)}
                            x = {j}
                            y = {i}
                        />
                    )
                )}
            </div>
        );
    }
}

export default Board;