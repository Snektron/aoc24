#include <bits/stdc++.h>

int main(int argc, char* argv[]) {
    auto in = std::ifstream(argc > 1 ? argv[1] : "input/04");
    in.seekg(0, std::ios_base::end);
    const auto size = in.tellg();
    in.seekg(0, std::ios_base::beg);

    auto grid = std::vector<std::string>();
    std::string line;
    while (std::getline(in, line)) {
        grid.push_back(std::move(line));
    }

    constexpr auto xmas = std::string_view{"XMAS"};
    constexpr auto mas = std::string_view{"MAS"};

    const auto get = [&](const auto x, auto y) {
        if (y < 0 || y >= grid.size()) {
            return -1;
        } else if (x < 0 || y > grid[9].size()) {
            return -1;
        } else {
            return static_cast<int>(grid[y][x]);
        }
    };

    auto part1 = 0;
    auto part2 = 0;

    for (auto y = 0; y < grid.size(); ++y) {
        for (auto x = 0; x < grid.size(); ++x) {
            auto mas_count = 0;
            for (auto dy = -1; dy <= 1; ++dy) {
                for (auto dx = -1; dx <= 1; ++dx) {
                    for (auto i = 0; i < xmas.size(); ++i) {
                        if (get(x + dx * i, y + dy * i) != xmas[i]) {
                            goto next;
                        }
                    }
                    ++part1;
                    next:
                        continue;

                }
            }

            for (const auto dy : {-1, 1}) {
                for (const auto dx : {-1, 1}) {
                    for (auto i = 0; i < mas.size(); ++i) {
                        if (get(x + dx * (i - 1), y + dy * (i - 1)) != mas[i]) {
                            goto next2;
                        }
                    }
                    ++mas_count;
                next2:
                    continue;
                }
            }

            part2 += mas_count / 2;
        }
    }

    std::cout << "part 1: " << part1 << std::endl;
    std::cout << "part 2: " << part2 << std::endl;
}
