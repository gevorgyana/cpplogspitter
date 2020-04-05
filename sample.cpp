#include <iostream>

class B
{
 public:
  B();
};

B::B()
{
  ;
}

class A {
 public:
  static void main()
  {
    B b;
  }
};

int main()
{
  A::main();
}
