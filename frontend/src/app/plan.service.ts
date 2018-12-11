import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class PlanService {
  apiUrl = "http://localhost:3000/getPlan";

  constructor(private http: HttpClient) { }

  getPlan(cntNodes, adjMat, cntMat, s1, s2, release, due) {
    var body = {
      "x": cntNodes,
      "y": adjMat,
      "z": cntMat,
      "s1": s1,
      "s2": s2,
      "r": release,
      "d": due
    };
    return this.http.post(this.apiUrl, body, { headers: new HttpHeaders({}) });
  }


}
