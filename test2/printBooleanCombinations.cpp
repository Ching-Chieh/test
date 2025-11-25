// bit manipulation ----------------------------------------------------------------------------------------------------
#include <iostream>
#include <vector>
using namespace std;

void printBooleanCombinations(int n) {
    int total = 1 << n; // total = 2^n
    for (int i = 0; i < total; ++i) {,
        for (int j = n - 1; j >= 0; --j) {
            // i=3 (二進位011) ((3 >> j) & 1) 取出位數 j=2取出0, j=1取出1
            cout << ((i >> j) & 1);
            if (j > 0) cout << ",";
        }
        cout << endl;
    }
}

int main() {
    int n;
    cout << "Enter n: ";
    cin >> n;

    printBooleanCombinations(n);

    return 0;
}


// recursion ----------------------------------------------------------------------------------------------------
#include <iostream>
#include <vector>
using namespace std;

void printBooleanCombinations(int n, vector<int>& combination, int index) {
    if (index == n) { // 遞迴終止：已填滿所有位置
        for (int i = 0; i < n; ++i) {
            cout << combination[i];
            if (i < n - 1) cout << ",";
        }
        cout << endl;
        return;
    }

    // 遞迴分支：當前位置放 0
    combination[index] = 0;
    printBooleanCombinations(n, combination, index + 1);

    // 遞迴分支：當前位置放 1
    combination[index] = 1;
    printBooleanCombinations(n, combination, index + 1);
}

int main() {
    int n;
    cout << "Enter n: ";
    cin >> n;

    vector<int> combination(n);
    printBooleanCombinations(n, combination, 0);

    return 0;
}


/*
R:
printBooleanCombinations <- function(n) {
  args=list()
  for (i in 1:n) args[[i]]=0:1
  do.call(expand.grid, args)
}
*/

// permutations ----------------------------------------------------------------------------------------------------
#include <iostream>
#include <set>
#include <vector>
#include <iomanip>
using namespace std;

int count = 0;
template<class T>
void permutations(vector<T>& a, const int k, const int m) {
    if (k == m) {
        cout << setw(2) << ++count << ": ";
        for (int i = 0; i <= m; i++) cout << a[i] << " ";
        cout << endl;
    } else {
        set<T> used;
        for (int i = k; i <= m; i++) {
            if (used.find(a[i]) != used.end()) continue;
            used.insert(a[i]);
            
            swap(a[k], a[i]);
            permutations(a, k+1, m);
            swap(a[k], a[i]);
        }
    }
}

int main() {
    //vector<char> a = {'a', 'b', 'b', 'c', 'c', 'c'};
    //permutations(a, 0, n-1);
    int n = 5;
    vector<int> a(n, 0);
    cout << setw(2) << ++count << ": ";
    for (const auto& num: a) cout << num << " ";
    cout << endl;
    for (int i = 0; i < n; i++) {
        a[i] = 1;
        permutations(a, 0, n-1);
    }
    
    return 0;
}
