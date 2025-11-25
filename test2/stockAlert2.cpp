#include <iostream>
#include <unordered_map>
#include <string>

using namespace std;

struct Alert {
    double alertPrice;
    bool active; // true: 等待觸發
};

unordered_map<string, unordered_map<int, Alert>> stockAlerts;
unordered_map<string, double> Price;

void triggerAlert(int userId, const string& stock, double price) {
    cout << "[ALERT] User " << userId << ": " << stock << " reached price " << price << endl;
}

void addAlert(int userId, const string& stock, double alertPrice) {
    stockAlerts[stock][userId] = {alertPrice, true};
    cout << "[INFO] User " << userId << " set " << stock << " alert @" << alertPrice << endl;
}

// 更新 alert 價格
bool updateAlertPrice(int userId, const string& stock, double newPrice) {
    auto stockIt = stockAlerts.find(stock);
    if (stockIt == stockAlerts.end()) return false;

    auto& userAlerts = stockIt->second;
    auto it = userAlerts.find(userId);
    if (it == userAlerts.end()) return false;

    it->second.alertPrice = newPrice;
    it->second.active = true; // 重啟 alert 等待觸發
    cout << "[INFO] User " << userId << " updated " << stock
         << " alert price to " << newPrice << endl;
    return true;
}

/*
// 刪除 alert
bool removeAlert(int userId, const string& stock) {
    auto stockIt = stockAlerts.find(stock);
    if (stockIt == stockAlerts.end()) return false;
    return stockIt->second.erase(userId) > 0;
	// 如果 userId 存在 → erase 刪除它 → 回傳 1 → 1 > 0 → true
	// 如果 userId 不存在 → erase 不做任何事 → 回傳 0 → 0 > 0 → false
}
*/

bool removeAlert(int userId, const string& stock) {
    auto stockIt = stockAlerts.find(stock);
    if (stockIt == stockAlerts.end()) {
        cout << "[INFO] Stock " << stock << " has no alerts." << endl;
        return false;
    }

    auto& userAlerts = stockIt->second;
    size_t erased = userAlerts.erase(userId);
    if (erased > 0) {
        cout << "[INFO] User " << userId << "'s alert for " << stock << " removed successfully." << endl;
        return true;
    } else {
        cout << "[INFO] User " << userId << " has no alert set for " << stock << "." << endl;
        return false;
    }
}


// 股票價格更新
void updatePrice(const string& stock, double price) {
    Price[stock] = price;

    auto stockIt = stockAlerts.find(stock);
    if (stockIt == stockAlerts.end()) return;

    auto& userAlerts = stockIt->second;

	/*
	for (auto& [userId, alert] : userAlerts) {} 等價於
	for (auto& p : userAlerts) {
		int userId = p.first;
		Alert& alert = p.second;
	}
	*/

    for (auto& [userId, alert] : userAlerts) {
        if (alert.active) {
            if (price >= alert.alertPrice) {
                triggerAlert(userId, stock, price);
                alert.active = false;
            }
        } else {
            // 價格跌回 alertPrice 以下 → 重啟 alert 等待觸發
            if (price < alert.alertPrice) {
                alert.active = true;
            }
        }
    }
}


int main() {
    addAlert(1, "AAPL", 150);
    addAlert(2, "AAPL", 155);
    updatePrice("AAPL", 200); // user1, user2 alert
	updatePrice("AAPL", 180);
	cout << endl;
    
    // 修改 alert price
    updateAlertPrice(1, "AAPL", 160);
    updatePrice("AAPL", 161); // user1 alert
    cout << endl;
    
    // 下跌 → 重啟 alert 等待觸發
    cout << "下跌至140:" << endl;
    cout << "目前alert price: user1 " << stockAlerts["AAPL"][1].alertPrice <<
                           ", user2 " << stockAlerts["AAPL"][2].alertPrice << endl;
    updatePrice("AAPL", 140);
    updatePrice("AAPL", 162); // user1, user2 alert
    cout << endl;
    // 移除 alert
    removeAlert(2, "AAPL");
    updatePrice("AAPL", 170); // user2 不會再alert

    return 0;
}
