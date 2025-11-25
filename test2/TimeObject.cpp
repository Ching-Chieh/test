#include <iostream>
using std::cout;
using std::endl;

class CTime
{
    private:
        int hour, min;
        double sec;
    
    public:
        CTime(int h, int m, double s):hour(h),min(m),sec(s) {}
        CTime() {}
        void set_time(int h, int m, double s) {
            hour=h;
            min=m;
            sec=s;
        }
        int get_hour() { return this->hour ;}
        int get_min() { return this->min ;}
        double get_sec() { return this->sec ;}
        void show_time() {
            cout << hour << " hr " << min << " min " << sec << " sec" << endl;
            cout << endl;
        }
        bool operator<(const CTime &time) {
            double sec1=this->hour*3600 + this->min*60 + this->sec;
            double sec2=time.hour*3600 + time.min*60 + time.sec;
            return sec1<sec2;
        }
        bool operator>(const CTime &time) {
            double sec1=this->hour*3600 + this->min*60 + this->sec;
            double sec2=time.hour*3600 + time.min*60 + time.sec;
            return sec1>sec2;
        }
        CTime operator+(const CTime &time) {
            int hh=this->hour+time.hour;
            int mm=this->min+time.min;
            double ss=this->sec+time.sec;
            
            int count_m=0, count_h=0;
            while(ss >= 60) {
                ss-=60;
                count_m++;
            }
            mm+=count_m;
            while(mm >= 60) {
                mm-=60;
                count_h++;
            }
            hh+=count_h;
            return CTime(hh,mm,ss);
        }
        CTime operator-(const CTime &time) {
            int hh=this->hour-time.hour;
            int mm=this->min-time.min;
            double ss=this->sec-time.sec;
            int count_m=0, count_h=0;
            if (*this > time) { // min, sec可能出現負數
                while(ss < 0) {
                    ss+=60;
                    count_m--;
                }
                mm+=count_m;
                while(mm < 0) {
                    mm+=60;
                    count_h--;
                }
                hh+=count_h;
            } else {
                while(ss > 0) {
                    ss-=60;
                    count_m++;
                }
                mm+=count_m;
                while(mm > 0) {
                    mm-=60;
                    count_h++;
                }
                hh+=count_h;
            }
            return CTime(hh,mm,ss);
        }
        CTime operator*(int num) {
            int hh = this->hour * num;
            int mm = this->min * num;
            double ss = this->sec * num;
            
            int count_m=0, count_h=0;
            while(ss >= 60) {
                ss-=60;
                count_m++;
            }
            mm+=count_m;
            while(mm >= 60) {
                mm-=60;
                count_h++;
            }
            hh+=count_h;
            return CTime(hh, mm, ss);
        }
        CTime operator/(int num) {
            double hh = (double)(this->hour) / num;
            double mm = (double)(this->min) / num;
            double ss = this->sec / num;
            
            // 處理小數部分
            mm+=(hh-(int)hh)*60;
            hh = (int)hh;
            ss+=(mm-(int)mm)*60;
            mm = (int)mm;
            
            // 不須處理>=60, 因為不會>=60
            // 小數部分最大=0.5，最多加30到右邊那一位數，右邊那一位數/2一定小於30，
            // 30 + 小於30的數 < 60
            
            return CTime(hh, mm, ss);
        }

};

CTime operator*(const int num, CTime &time) {
    int hh = time.get_hour() * num;
    int mm = time.get_min() * num;
    double ss = time.get_sec() * num;
    
    int count_m=0, count_h=0;
    while(ss >= 60) {
        ss-=60;
        count_m++;
    }
    mm+=count_m;
    while(mm >= 60) {
        mm-=60;
        count_h++;
    }
    hh+=count_h;
    return CTime(hh, mm, ss);
}


int main(void)
{
    CTime t1(4, 23, 56.3);
    CTime t2(5, 45, 30.3);
    CTime t3;
    
    t3=t1-t2;
    cout << "t1-t2: ";
    t3.show_time();
    
    t3=t2-t1;
    cout << "t2-t1: ";
    t3.show_time();
    
    t3=t1*3;
    cout << "t1*3: ";
    t3.show_time();
    
    t3=3*t1;
    cout << "3*t1: ";
    t3.show_time();
    
    t3=t2*3;
    cout << "t2*3: ";
    t3.show_time();
    
    t3=3*t2;
    cout << "3*t2: ";
    t3.show_time();    
    
    t3=t1/2;
    cout << "t1/2: ";
    t3.show_time();
    
    t3=t2/2;
    cout << "t2/2: ";
    t3.show_time();  
    return 0;
}

