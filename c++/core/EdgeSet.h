#ifndef EDGESET_H_
#define EDGESET_H_

#include "Point3D.h"
#include "utils.h"
#include <string>
#include "Object.h"
#include "VisibleE.h"
#include "Edge.h"
#include "EdgeW.h"
#include "Edge2W.h"

using namespace std;

template < class P=Point, class E=Edge<P> >
class EdgeSet : public VisibleE
{
public:

  vector< Point* >* points;

  //Points in the cloud
  vector< E* > edges;

  EdgeSet() : VisibleE() {}

  EdgeSet(string filename);

  ~EdgeSet();

  void setPointVector(vector< Point* >* _points);

  void draw();

  bool load(istream &in);

  void save(ostream &out);

  void addEdge(int p1idx, int p2idx);

  int findEdgeBetween(int p1idx, int p2idx);
};


// FOR NOW ON, DEFINITIONS HERE, BUT SHOULD CHANGE

template< class P, class E>
EdgeSet<P,E>::EdgeSet(string filename)
{
  loadFromFile(filename);
}

template< class P, class E>
EdgeSet<P,E>::~EdgeSet()
{
  // printf("EdgeSet::freeing edges\n");
  for(int i = 0; i < edges.size(); i++)
    delete (edges[i]);
  // delete (points);
}

template< class P, class E>
bool EdgeSet<P,E>::load(istream& in){
  int start = in.tellg();
  string s;
  in >> s;
  int orig = s.find("<EdgeSet");
  if(orig == string::npos){
    printf("EdgeSet::error load called when there is no beginning of Edge\n");
    in.seekg(start);
    return false;
  }
  in >> s;
  E* et = new E();
  orig = s.find(et->className()+">");
  delete et;
  if(orig == string::npos){
    printf("EdgeSet::error load called when there is no type of the class\n");
    in.seekg(start);
    return false;
  }

  if(!VisibleE::load(in))
    return false;
  E* e = new E();
  while(e->load(in)){
    edges.push_back(e);
    e = new E();
  }
  //delete e;
  in >> s;
  if(s.find("</EdgeSet>")==string::npos){
    printf("EdgeSet::error load can not find </EdgeSet>\n");
    in.seekg(start);
    return false;
  }

  return true;
}

template< class P, class E>
void EdgeSet<P,E>::save(ostream &out){
  E* et = new E();

  out << "<EdgeSet " << et->className() << ">" << std::endl;
  VisibleE::save(out);
  for(int i = 0; i < edges.size(); i++)
    edges[i]->save(out);
  out << "</EdgeSet>" << std::endl;
  delete et;
}

template< class P, class E>
void EdgeSet<P,E>::draw()
{
  // VisibleE::draw();
  glLineWidth(this->v_radius);
  for(int i = 0; i < edges.size(); i++)
    edges[i]->draw();

}

template< class P, class E>
void EdgeSet<P,E>::setPointVector(vector< Point* >* _points)
{
  points = _points;
  for(uint i = 0; i < edges.size(); i++)
    edges[i]->points = points;
}

template< class P, class E>
void EdgeSet<P,E>::addEdge(int p1idx, int p2idx)
{
  edges.push_back(new E(points, p1idx, p2idx));
}

template< class P, class E>
int EdgeSet<P,E>::findEdgeBetween(int p0, int p1)
{
  int toReturn = -1;
  for(int nE = 0; nE < edges.size(); nE++)
    if( ( (edges[nE]->p0 == p0) && (edges[nE]->p1 == p1) ) ||
        ( (edges[nE]->p0 == p1) && (edges[nE]->p1 == p0) )  )
      toReturn = nE;
  return toReturn;
}


#endif
