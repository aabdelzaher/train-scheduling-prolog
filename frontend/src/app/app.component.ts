import { Component, AfterViewInit } from '@angular/core';
import { PlanService } from './plan.service';
import { Network, DataSet, Node, Edge, IdType } from 'vis';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements AfterViewInit{
  title = 'ElsekkaEl7adeed';
  cntNodes = 0;
  inf = 1000;
  adjMat: number[][];
  cntMat: number[][];
  from: number;
  to: number;
  weight: number;
  multi: boolean;
  edges;

  s1: number;
  s2: number;
  release: number;
  due: number;

  stations1: number[];
  stations2: number[];
  releaseTimes: number[];
  dueTimes: number[];


  addEdge() {
    if (this.from == null || this.to == null)
      alert("please enter the two nodes");
    else
      if (Math.min(this.from, this.to) <= 0 || Math.max(this.from, this.to) > this.cntNodes)
        alert("values must be between 1 and " + this.cntNodes);
      else {
        this.edges.push([this.from - 1, this.to - 1, this.weight, this.multi ? 2 : 1]);
      }
  }

  constructor(private planService: PlanService) {
    this.stations1 = [];
    this.stations2 = [];
    this.releaseTimes = [];
    this.dueTimes = [];
  }

  ngAfterViewInit(){
    this.resetGraph();
  }

  generateGraph() {
    var self = this;
    this.adjMat = new Array(this.cntNodes);
    this.cntMat = new Array(this.cntNodes);
    for (var i = 0; i < this.cntNodes; i++) {
      this.adjMat[i] = new Array(this.cntNodes).fill(this.inf);
      this.cntMat[i] = new Array(this.cntNodes).fill(this.inf);
      this.adjMat[i][i] = 0;
      this.cntMat[i][i] = 0;
    }
    this.edges.forEach(function (e) {
      self.adjMat[e[0]][e[1]] = e[2];
      self.cntMat[e[0]][e[1]] = e[3];
    });

    var nodesArray = [];
    for (var i = 1; i <= this.cntNodes; i++) {
      var name = 'Station ' + i;
      nodesArray.push({ id: i, label: name });
    }

    var nodes = new DataSet(nodesArray);

    var edgesArray = [];
    this.edges.forEach(e => {
      edgesArray.push({ from: e[0] + 1, to: e[1] + 1 });
    });

    var edgees = new DataSet(edgesArray);

    // create a network
    var container = document.getElementById('mynetwork');

    // provide the data in the vis format
    var data = {
      nodes: nodes,
      edges: edgees
    };
    var options = {};

    // initialize your network!
    var network = new Network(container, data, options);
  }

  resetGraph() {
    this.cntNodes=2;
    this.edges = [[0, 1, 10, 1]];
    this.generateGraph();
  }

  addTrain() {
    this.stations1.push(this.s1);
    this.stations2.push(this.s2);
    this.releaseTimes.push(this.release);
    this.dueTimes.push(this.due);
  }

  getPlan() {
    this.planService.getPlan(this.cntNodes, this.adjMat, this.cntMat, this.stations1, this.stations2, this.releaseTimes, this.dueTimes)
      .subscribe(data => {
        console.log(data);
      });
  }

}

