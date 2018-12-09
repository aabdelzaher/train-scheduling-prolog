import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class PlanService {
  apiUrl = "http://192.168.3.170:3000/omar";

  constructor(private http: HttpClient) { }

  getPlan(cntNodes, adjMat, cntMat) {
    var body = {
      "x": 3,
      "y": [[0, 1, 100], [1, 0, 1], [100, 1, 0]],
      "z": [[0, 2, 2], [2, 0, 2], [2, 2, 0]],
      "s1": [2, 1],
      "s2": [1, 3],
      "r": [1, 1],
      "d": [2, 3]
    };
    this.http.post(this.apiUrl, body, { headers: new HttpHeaders({}) }).subscribe(res => {
      console.log(res);
    });
  }


}
