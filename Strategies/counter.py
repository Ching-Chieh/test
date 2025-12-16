from collections import Counter

class MyCounter(Counter):
    def less_common(self, n=None):
        items = sorted(self.items(), key=lambda x: x[1])
        if n is None:
            return items
        return items[:n]


mc = MyCounter("abracadabra")
print(mc.less_common())
print(mc.less_common(2))

# closure
def new_counter():
    i = 0
    
    def counter():
        nonlocal i
        i += 1
        return i
    
    return counter


counter_one = new_counter()
counter_two = new_counter()

print(counter_one())  # 1
print(counter_one())  # 2
print(counter_two())  # 1
print(counter_two())  # 2

# class
class Counter:
    def __init__(self):
        self.i = 0

    def __call__(self):
        self.i += 1
        return self.i

counter_one = Counter()
counter_two = Counter()

print(counter_one())  # 1
print(counter_one())  # 2
print(counter_two())  # 1
print(counter_two())  # 2

# #include <iostream>
# #include <functional>

# std::function<int()> new_counter() {
#     int i = 0;
#     return [i]() mutable {
#         i++;
#         return i;
#     };
# }

# int main() {
#     auto counter_one = new_counter();
#     auto counter_two = new_counter();

#     std::cout << counter_one() << std::endl; // 1
#     std::cout << counter_one() << std::endl; // 2
#     std::cout << counter_two() << std::endl; // 1
#     std::cout << counter_two() << std::endl; // 2

#     return 0;
# }

