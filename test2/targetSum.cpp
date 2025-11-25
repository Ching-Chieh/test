// queue ----------------------------------------------------------------------------------------------------
#include <iostream>
#include <vector>
#include <queue>
using namespace std;

class Solution {
public:
    int targetSum(vector<int>& nums, int target) {
        int n = nums.size();
        int ways = 0;

        // {目前加總, index}
        queue<pair<int, int>> q;
        q.push({0, 0});

        while (!q.empty()) {
            auto [curr_sum, index] = q.front();
            q.pop();

            if (index == n) {
                if (curr_sum == target) {
                    ways++;
                }
            } else {
                q.push({curr_sum + nums[index], index + 1});
                q.push({curr_sum - nums[index], index + 1});
            }
        }

        return ways;
    }
};
int main() {
    Solution sol;
    vector<int> nums = {1, 1, 1, 1, 1};
    int target = 3;

    int result = sol.targetSum(nums, target);
    cout << "Number of ways: " << result << endl; // Output: 5

    return 0;
}
/*
舉例
vector<int> nums = {1, 2}, target = 1
初始狀態
q = [ (0, 0) ]
第一次迴圈
curr_sum = 0, index = 0
q = []
q = [ (1, 1), (-1, 1) ]
第二次迴圈
curr_sum = 1, index = 1
q = [ (-1, 1) ]
q = [ (-1, 1), (3, 2), (-1, 2) ]
第三次迴圈
curr_sum = -1, index = 1
q = [ (3, 2), (-1, 2) ]
q = [ (3, 2), (-1, 2), (1, 2), (-3, 2) ]
第四次迴圈
curr_sum = 3, index = 2 (ways不變)
q = [ (-1, 2), (1, 2), (-3, 2) ]
第五次迴圈
curr_sum = -1, index = 2 (ways不變)
q = [ (1, 2), (-3, 2) ]
第六次迴圈
curr_sum = 1, index = 2 (ways++)
q = [ (-3, 2) ]
第七次迴圈
curr_sum = -3, index = 2 (ways不變)
q = []
*/

// 遞迴法 ----------------------------------------------------------------------------------------------------
#include <iostream>
#include <vector>
using std::cout;
using std::endl;
using std::vector;

class Solution {
public:
    int findTargetSumWays(vector<int>& nums, int target) {
        return backtracking(nums, 0, 0, target);
    }

private:
    int backtracking(const vector<int>& nums, int pos, int sum, int target) {
        if (pos == nums.size()) {
            return sum == target ? 1 : 0;
        }

        int count = backtracking(nums, pos + 1, sum + nums[pos], target);
        count += backtracking(nums, pos + 1, sum - nums[pos], target);

        return count;
    }
};

int main() {
    Solution sol;
    vector<int> nums = {1, 1, 1, 1, 1};
    int target = 3;

    int result = sol.findTargetSumWays(nums, target);
    cout << "Number of ways: " << result << endl;
    return 0;
}
// R列出所有 ----------------------------------------------------------------------------------------------------
cat("\014")
rm(list=ls())
nums=rep(1,5)
target=3
sign_combinations <- expand.grid(rep(list(c(1, -1)), length(nums)))
results <- apply(sign_combinations, 1, function(signs) sum(signs * nums))
df=cbind(sign_combinations, sum = results)
df
nrow(df[df$sum == target, ])

// 轉成Subset sum problem, 用DP法 ----------------------------------------------------------------------------------------------------
#include <iostream>
#include <vector>
using namespace std;

class Solution {
public:
    int targetSum(vector<int>& nums, int target) {
        int sum = 0;
        for (int num : nums) 
            sum += num;
        
        if (sum < target || (sum - target) % 2 != 0)
            return 0;
        
        int newTarget = (sum - target) / 2;
        
        vector<int> dp(newTarget + 1, 0);
        dp[0] = 1;
        
        for (int num : nums)
            for (int j = newTarget; j >= num; j--)
                dp[j] += dp[j - num];
        
        return dp[newTarget];
    }
};

int main() {
    Solution sol;
    vector<int> nums = {1, 1, 1, 1, 1};
    int target = 3;
    int result = sol.targetSum(nums, target);
    cout << "Number of ways: " << result << endl; // Output: 5

    return 0;
}
