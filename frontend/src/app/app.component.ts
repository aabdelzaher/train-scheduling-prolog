import { Component, AfterViewInit } from '@angular/core';
import { PlanService } from './plan.service';
import { Network, DataSet, Node, Edge, IdType } from 'vis';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements AfterViewInit {
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
  plan;

  s1: number;
  s2: number;
  release: any;
  due: any;

  stations1: number[];
  stations2: number[];
  releaseTimes: number[];
  dueTimes: number[];

  myTime: any;

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

  ngAfterViewInit() {
    this.resetGraph();
  }

  getTime(t) {
    var am = (t < 720);
    var h = Math.floor(t / 60);
    if (h > 12)
      h -= 12;
    var m = t % 60;
    var h2 = "" + h;
    if (h < 10)
      h2 = "0" + h;
    var m2 = "" + m;
    if (m < 10)
      m2 = "0" + m;
    return h2 + ":" + m2 + " " + (am ? "AM" : "PM");
  }

  getMinutes(t) {
    if (!t)
      return -1;
    var sa = t.split(':');
    return parseInt(sa[0]) * 60 + parseInt(sa[1]);
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
      self.adjMat[e[1]][e[0]] = e[2];
      self.cntMat[e[1]][e[0]] = e[3];
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
    this.cntNodes = 3;
    this.edges = [[0, 1, 10, 1], [1, 2, 20, 1]];
    this.generateGraph();
  }

  addTrain() {
    if (Math.min(this.s1, this.s2) < 1 || Math.max(this.s1, this.s2) > this.cntNodes) {
      alert("Start and end stations must be between 1 and " + this.cntNodes);
      return;
    }
    if (this.s1 == this.s2) {
      alert("A train must be between two different stations");
      return;
    }

    var releaseTime = this.getMinutes(this.release);
    var dueTime = this.getMinutes(this.due);

    if (Math.min(releaseTime, dueTime) < 0) {
      alert("Please enter release and due time correctly");
      return;
    }
    if (Math.min(releaseTime, dueTime) < 0 || Math.max(releaseTime, dueTime) >= 1440) {
      alert("Please select a valid release and due time");
      return;
    }
    if (this.release >= this.due) {
      alert("Due time must be after the release time");
      return;
    }

    this.stations1.push(this.s1);
    this.stations2.push(this.s2);
    this.releaseTimes.push(releaseTime);
    this.dueTimes.push(dueTime);
  }

  getPlan() {

    if (this.stations1.length == 0) {
      alert("please add trains to find a plan for");
      return;
    }

    this.planService.getPlan(this.cntNodes, this.adjMat, this.cntMat, this.stations1, this.stations2, this.releaseTimes, this.dueTimes)
      .subscribe(data => {
        console.log(data);
        this.plan = data;
      });
  }

}

