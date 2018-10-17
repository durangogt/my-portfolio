import React from 'react';
import ReactDOM from 'react-dom';
import ExampleWork from './example-work';

const myWork = [
    {
        'title': "Serverless Notes Reader",
        'image': {
            'desc': "example screenshot of a project involving code",
            'src': "images/example1.png",
            'comment': ""
        }
    },
    {
        'title': "PyGame Board Game",
        'image': {
            'desc': "example screenshot of a project involving chemistry",
            'src': "images/example2.png",
            'comment': ""
        }
    },
    {
        'title': "Saline",
        'image': {
            'desc': "example screenshot of a project involving cats",
            'src': "images/example3.png",
            'comment': ""
        }
    }        
]

ReactDOM.render(<ExampleWork work={myWork}/>, document.getElementById('example-work'));