import React from 'react';
import { colorToCss } from './Game';

class Square extends React.Component {
    render() {
        return (
            <button style={{ backgroundColor: colorToCss(this.props.value) }} onClick = {() => this.props.onClick(this.props.x, this.props.y)}/>
        );
    }
}

export default Square;