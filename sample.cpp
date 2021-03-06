#include <iostream>

/*
 * a multiline comment must be skipped even if it
 * has {} or just {, simply ignore me!
 */

namespace ns
{
class N
{
 public:
  // this is a comment
  // this class's lifetime starting point
  // will not be traced because it has
  // no constructor definition in source code

  // there is nothing that I can do about it
  // anyway it would not be useful cuz it would not do
  // anything smart
  N() = default;
};

class M
{
 public: // this must be processed!
  M()
  {

  }
};
} // ns

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
