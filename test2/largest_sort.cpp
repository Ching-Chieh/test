// largest, sort 
#include <iostream>
#include <algorithm>

using namespace std;
class CWin {
    private:
    char id;
    int width, height;
    int area() { return width*height; }

    public:
    CWin(char i, int w, int h): id(i), width(w), height(h) {}
    CWin() {}
	char get_id() { return id; }
	int get_width() { return width; }
	int get_height() { return height; }
	// friend
	friend void largest_f(CWin [], int);
	friend void sort_f(CWin [], int);
	// static
    static void largest_s(CWin [], int);
	static void sort_s(CWin [], int);
};

void print(CWin win[], int size) {
    cout << "id width height\n";
	for (size_t i = 0; i < size; i++)
		cout << win[i].get_id() << " " << win[i].get_width() << " " << win[i].get_height() << " " << endl;
	cout << endl;
}

// friend
void largest_f(CWin win[], int size) {
    int max = 0, max_index = 0;
    for (size_t i = 0; i < size; i++) {
        if (win[i].area() > max) {
            max_index = i;
            max = win[i].area();
        }
    }
    cout << win[max_index].id << " Window is largest. Its area is " << max << "." << endl;
}
void sort_f(CWin win[], int size) {
    // bubble sort
    for (size_t i = 0; i < size - 1; i++)
        for (size_t j = i + 1; j < size; j++)
            if (win[i].area() < win[j].area())
                swap(win[i], win[j]);
	
	for (size_t i = 0; i < size; i++)
		cout << win[i].id << " - area= " << win[i].area() << endl;
	cout << endl;
}

// static
void CWin::largest_s(CWin win[], int size) {
	int max = 0, max_index = 0;
	for (size_t i = 0; i < size; i++) {
		if (win[i].area() > max) {
			max_index = i;
			max = win[i].area();
		}
	}
	cout << win[max_index].id << " Window is largest. Its area is " << max << "." << endl;
}
void CWin::sort_s(CWin win[], int size) {
	// bubble sort
	for (size_t i = 0; i < size - 1; i++)
		for (size_t j = i + 1; j < size; j++)
			if (win[i].area() < win[j].area())
				swap(win[i], win[j]);
	
	for (size_t i = 0; i < size; i++)
		cout << win[i].id << " - area= " << win[i].area() << endl;
	cout << endl;
}

int main() {
    cout << "----------------------------------------------------" << endl;
    CWin win[3] = {
		CWin('A', 20, 80),
        CWin('B', 50, 50),
        CWin('C', 70, 20)
	};
	CWin win_sorted[3];
	
	largest_f(win, 3);
	CWin::largest_s(win, 3);
	
	// friend
    cout << "friend -----------------------------\n";
	for (size_t i = 0; i < 3; i++)
		win_sorted[i] = win[i];
	
	cout << "before:\n";
	print(win_sorted, 3);
	cout << "sort_f:\n";
	sort_f(win_sorted, 3);
	cout << "after:\n";
	print(win_sorted, 3);
	
	// static
	cout << "static -----------------------------\n";
	for (size_t i = 0; i < 3; i++)
		win_sorted[i] = win[i];
	
    cout << "before:\n";
	print(win_sorted, 3);
	cout << "sort_s:\n";
	CWin::sort_s(win_sorted, 3);
	cout << "after:\n";
	print(win_sorted, 3);
	
	
	
    cout << "----------------------------------------------------" << endl;
    return 0;
}

