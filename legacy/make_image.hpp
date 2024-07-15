#include <vector>
#include <complex>
std::vector<std::vector<std::complex<double>>> make_image(std::pair<double,double> xlim, std::pair<double,double> ylim, int res, std::complex<double> (*func)(const std::complex<double>&));