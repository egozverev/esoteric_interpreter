void operator() (int& x, std::string& y) {}
void operator() (std::string& x, int& y) {}
void operator() (int& x, bool& y) {}
void operator() (bool& x, int& y) {}
void operator() (int& x, double& y) {}
void operator() (double& x, int& y) {}
void operator() (int& x, None& y) {}
void operator() (None& x, int& y) {}
void operator() (std::string& x, bool& y) {}
void operator() (bool& x, std::string& y) {}
void operator() (std::string& x, double& y) {}
void operator() (double& x, std::string& y) {}
void operator() (std::string& x, None& y) {}
void operator() (None& x, std::string& y) {}
void operator() (bool& x, double& y) {}
void operator() (double& x, bool& y) {}
void operator() (bool& x, None& y) {}
void operator() (None& x, bool& y) {}
void operator() (double& x, None& y) {}
void operator() (None& x, double& y) {}
void operator() (None&, None&) {}
void operator() (bool&, bool&) {}
