using System;
using System.IO;
using System.Linq;
using System.Diagnostics;
using System.Collections.Generic;


class PortfolioRiskCalculator
{
    public static double[,] ReadCsv(string fileName)
    {
        var lines = File.ReadAllLines(fileName).Skip(1).ToArray(); // Skip header line and convert to array
        int rows = lines.Length;
        int cols = lines[0].Split(',').Length;

        double[,] matrix = new double[rows, cols];
        for (int i = 0; i < rows; i++)
        {
            var values = lines[i].Split(',').Select(double.Parse).ToArray();
            for (int j = 0; j < cols; j++)
            {
                matrix[i, j] = values[j];
            }
        }
        return matrix;
    }

    public static double[] CalculateLoss(double[,] priceMatrix, double[] portfolio)
    {
        int numberOfAssets = priceMatrix.GetLength(1);
        int numberOfScenarios = priceMatrix.GetLength(0) - 1;
        double[] portfolioValue = new double[numberOfScenarios];

        for (int i = 0; i < numberOfScenarios; i++)
        {
            for (int j = 0; j < numberOfAssets; j++)
            {
                portfolioValue[i] += portfolio[j] * priceMatrix[i + 1, j] / priceMatrix[i, j];
            }
        }

        double[] loss = new double[numberOfScenarios];
        for (int i = 0; i < numberOfScenarios; i++)
        {
            loss[i] = portfolio.Sum() - portfolioValue[i];
        }

        return loss;
    }

    public static (double VaR, double ES, double VaRLower, double VaRUpper) Traditional(double[] x)
    {
        double[] loss = (double[])x.Clone();
        int numberOfScenarios = loss.Length;
        Array.Sort(loss);
        Array.Reverse(loss);
        int num = (int)Math.Floor(numberOfScenarios * 0.01);

        double VaR = loss[num - 1];
        double ES = loss.Take(num - 1).Average();
        double lossMean = loss.Average();
        double lossSd = Math.Sqrt(CalculateVariance(loss));

        double SE = 1 / MathNet.Numerics.Distributions.Normal.PDF(lossMean, lossSd, MathNet.Numerics.Distributions.Normal.InvCDF(lossMean, lossSd, 0.99)) *
                    Math.Sqrt(0.01 * 0.99 / numberOfScenarios);
        double z = Qnorm(0.99);
        double VaRLower = VaR - z * SE;
        double VaRUpper = VaR + z * SE;

        return (VaR, ES, VaRLower, VaRUpper);
    }
    
    public static (double VaR, double ES) TraditionalWeighting(double[] x)
    {
        double[] loss = (double[])x.Clone();
        var sorted = loss
           .Select((x, i) => new KeyValuePair<double, int>(x, i))
           .OrderByDescending(x => x.Key)
           .ToArray();

        loss = sorted.Select(x => x.Key).ToArray();
        int[] scenarioNumber = sorted.Select(x => x.Value).ToArray();

        for (int i = 0; i < scenarioNumber.Length; i++)
        {
            scenarioNumber[i]++;
        }

        int numberOfScenarios = loss.Length;
        double lambda = 0.995;
        double[] weight = new double[numberOfScenarios];

        for (int i = 0; i < numberOfScenarios; i++)
        {
            weight[i] = Math.Pow(lambda, numberOfScenarios - scenarioNumber[i]) * (1 - lambda) / (1 - Math.Pow(lambda, numberOfScenarios));
        }

        double[] cumWeight = new double[numberOfScenarios];
        for (int i = 0; i < numberOfScenarios; i++)
        {
            cumWeight[i] = weight.Take(i + 1).Sum();
        }

        int num = 0;
        while (cumWeight[num] < 0.01) num++;

        double value = 0;
        for (int i = 0; i < num; i++)
        {
            value += loss[i] * weight[i];
        }

        double VaR = loss[num];
        double ES = (value + (0.01 - cumWeight[num - 1]) * loss[num]) / 0.01;

        return (VaR, ES);
    }

    public static (double VaR, double ES) AdjustedLoss(double[] x)
    {
        double[] loss = (double[])x.Clone();
        int numberOfScenarios = loss.Length;
        double[] variance = new double[numberOfScenarios];
        variance[0] = CalculateVariance(loss);
        double lambda = 0.94;

        for (int i = 1; i < numberOfScenarios; i++)
        {
            variance[i] = lambda * variance[i - 1] + (1 - lambda) * Math.Pow(loss[i - 1], 2);
        }

        double[] adjLoss = new double[numberOfScenarios];
        for (int i = 0; i < numberOfScenarios; i++)
        {
            adjLoss[i] = loss[i] * Math.Sqrt(variance.Last() / variance[i]);
        }

        Array.Sort(adjLoss);
        Array.Reverse(adjLoss);
        int num = (int)Math.Floor(numberOfScenarios * 0.01);

        double VaR = adjLoss[num - 1];
        double ES = adjLoss.Take(num - 1).Average();

        return (VaR, ES);
    }

    public static (double VaR, double ES) VolatilityScaling(double[,] priceMatrix, double[] portfolio)
    {
        int numberOfPrices = priceMatrix.GetLength(0);
        int numberOfScenarios = numberOfPrices - 1;
        int numberOfAssets = priceMatrix.GetLength(1);

        double[,] multiplierMatrix = new double[numberOfScenarios, numberOfAssets];
        for (int j = 0; j < numberOfAssets; j++)
        {
            double[] price = GetColumn(priceMatrix, j);
            double[] multiplier = CalculateMultiplier(price);

            for (int i = 0; i < numberOfScenarios; i++)
            {
                multiplierMatrix[i, j] = multiplier[i];
            }
        }

        double[] portfolioValue = new double[numberOfScenarios];
        for (int i = 0; i < numberOfScenarios; i++)
        {
            for (int j = 0; j < numberOfAssets; j++)
            {
                portfolioValue[i] += portfolio[j] * multiplierMatrix[i, j];
            }
        }

        double[] loss = new double[numberOfScenarios];
        for (int i = 0; i < numberOfScenarios; i++)
        {
            loss[i] = portfolio.Sum() - portfolioValue[i];
        }

        Array.Sort(loss);
        Array.Reverse(loss);
        int num = (int)Math.Floor(numberOfScenarios * 0.01);

        double VaR = loss[num - 1];
        double ES = loss.Take(num - 1).Average();

        return (VaR, ES);
    }

    public static (double VaR, double ES) EqualWeight(double[,] returnMatrix, double[] portfolio)
    {
        double[,] covm = GetCovarianceMatrix(returnMatrix);
        double portfolioVariance = 0;

        for (int i = 0; i < portfolio.Length; i++)
        {
            for (int j = 0; j < portfolio.Length; j++)
            {
                portfolioVariance += portfolio[i] * covm[i, j] * portfolio[j];
            }
        }

        double VaR = Math.Sqrt(portfolioVariance) * Qnorm(0.99);
        double ES = Math.Sqrt(portfolioVariance) * Math.Exp(-Math.Pow(Qnorm(0.99), 2) / 2) / (Math.Sqrt(2 * Math.PI) * 0.01);

        return (VaR, ES);
    }

    public static (double VaR, double ES) EWMA(double[,] returnMatrix, double[] portfolio)
    {
        double[,] covMatrix = GetEWMACovarianceMatrix(returnMatrix);

        double portfolioVariance = 0;
        for (int i = 0; i < portfolio.Length; i++)
        {
            for (int j = 0; j < portfolio.Length; j++)
            {
                portfolioVariance += portfolio[i] * covMatrix[i, j] * portfolio[j];
            }
        }

        double VaR = Math.Sqrt(portfolioVariance) * Qnorm(0.99);
        double ES = Math.Sqrt(portfolioVariance) * Math.Exp(-Math.Pow(Qnorm(0.99), 2) / 2) / (Math.Sqrt(2 * Math.PI) * 0.01);

        return (VaR, ES);
    }

    // Helper functions

    private static double Qnorm(double x)
    {
        return MathNet.Numerics.Distributions.Normal.InvCDF(0, 1, x);
    }

    private static double[] GetColumn(double[,] matrix, int column)
    {
        int rows = matrix.GetLength(0);
        double[] columnData = new double[rows];

        for (int i = 0; i < rows; i++)
        {
            columnData[i] = matrix[i, column];
        }

        return columnData;
    }

    private static double[] CalculateMultiplier(double[] price)
    {
        double[] returns = GetReturn(price);
        double[] volatility = CalculateVolatility(returns);
        double[] multiplier = new double[returns.Length];

        for (int i = 0; i < multiplier.Length; i++)
        {
            multiplier[i] = (price[i] + (price[i + 1] - price[i]) * volatility.Last() / volatility[i]) / price[i];
        }

        return multiplier;
    }

    private static double[] GetReturn(double[] prices)
    {
        double[] returns = new double[prices.Length - 1];
        for (int i = 0; i < prices.Length - 1; i++)
        {
            returns[i] = prices[i + 1] / prices[i] - 1;
        }
        return returns;
    }

    public static double[,] GetReturnMatrix(double[,] priceMatrix)
    {
        int M = priceMatrix.GetLength(0); // Number of rows
        int N = priceMatrix.GetLength(1); // Number of columns
        double[,] returnMatrix = new double[M - 1, N];

        for (int j = 0; j < N; j++) // Iterate over columns
        {
            double[] columnPrices = new double[M];
            for (int i = 0; i < M; i++)
            {
                columnPrices[i] = priceMatrix[i, j];
            }

            double[] columnReturns = GetReturn(columnPrices);

            for (int i = 0; i < M - 1; i++)
            {
                returnMatrix[i, j] = columnReturns[i];
            }
        }

        return returnMatrix;
    }

    private static double CalculateVariance(double[] x, double[]? y = null)
    {
        if (y == null) y = x;
        double meanx = x.Average();
        double meany = y.Average();
        return x.Select((xi, index) => (xi - meanx) * (y[index] - meany)).Sum() / (x.Length - 1);
    }

    private static double CalculateEWMAVariance(double[] x, double[]? y = null, double lambda = 0.94)
    {
        if (y == null) y = x;

        double value = CalculateVariance(x, y);
        int N = x.Length;

        for (int i = 0; i < N; i++)
        {
            value = lambda * value + (1 - lambda) * x[i] * y[i];
        }

        return value;
    }

    private static double[] CalculateVolatility(double[] returns)
    {
        double[] variance = new double[returns.Length + 1];
        double[] volatility = new double[returns.Length + 1];
        variance[0] = CalculateVariance(returns);
        double lambda = 0.94;

        for (int i = 1; i < variance.Length; i++)
        {
            variance[i] = variance[i - 1] * lambda + (1 - lambda) * returns[i - 1] * returns[i - 1];
        }

        for (int i = 0; i < variance.Length; i++)
        {
            volatility[i] = Math.Sqrt(variance[i]);
        }

        return volatility;
    }

    private static double[,] GetCovarianceMatrix(double[,] matrix)
    {
        int n = matrix.GetLength(0);
        int p = matrix.GetLength(1);
        double[,] S = new double[p, p];

        double[,] identity = new double[n, n];
        for (int i = 0; i < n; i++)
        {
            identity[i, i] = 1;
        }

        double[,] oneMatrix = new double[n, n];
        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < n; j++)
            {
                oneMatrix[i, j] = 1;
            }
        }

        double[,] tempMatrix = MatrixSubtract(identity, MatrixMultiply(1.0 / n, oneMatrix));
        S = MatrixMultiply(1.0 / (n - 1), MatrixMultiply(MatrixTranspose(matrix), MatrixMultiply(tempMatrix, matrix)));

        return S;
    }

    private static double[,] GetEWMACovarianceMatrix(double[,] returnMatrix)
    {
        int N = returnMatrix.GetLength(1);
        double[,] covMatrix = new double[N, N];

        for (int j = 0; j < N; j++)
        {
            double[] returnColumn = new double[returnMatrix.GetLength(0)];
            for (int i = 0; i < returnMatrix.GetLength(0); i++)
            {
                returnColumn[i] = returnMatrix[i, j];
            }
            covMatrix[j, j] = CalculateEWMAVariance(returnColumn);
        }

        for (int i = 0; i < N - 1; i++)
        {
            for (int j = i + 1; j < N; j++)
            {
                double[] returnColumnI = new double[returnMatrix.GetLength(0)];
                double[] returnColumnJ = new double[returnMatrix.GetLength(0)];

                for (int k = 0; k < returnMatrix.GetLength(0); k++)
                {
                    returnColumnI[k] = returnMatrix[k, i];
                    returnColumnJ[k] = returnMatrix[k, j];
                }

                covMatrix[i, j] = CalculateEWMAVariance(returnColumnI, returnColumnJ);
                covMatrix[j, i] = covMatrix[i, j];
            }
        }

        return covMatrix;
    }

    private static double[,] MatrixMultiply(double scalar, double[,] matrix)
    {
        int rows = matrix.GetLength(0);
        int cols = matrix.GetLength(1);
        double[,] result = new double[rows, cols];

        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < cols; j++)
            {
                result[i, j] = scalar * matrix[i, j];
            }
        }

        return result;
    }

    private static double[,] MatrixMultiply(double[,] matrix1, double[,] matrix2)
    {
        int rows1 = matrix1.GetLength(0);
        int cols1 = matrix1.GetLength(1);
        int rows2 = matrix2.GetLength(0);
        int cols2 = matrix2.GetLength(1);

        if (cols1 != rows2)
        {
            throw new ArgumentException("Matrix dimensions do not match for multiplication.");
        }

        double[,] result = new double[rows1, cols2];

        for (int i = 0; i < rows1; i++)
        {
            for (int j = 0; j < cols2; j++)
            {
                for (int k = 0; k < cols1; k++)
                {
                    result[i, j] += matrix1[i, k] * matrix2[k, j];
                }
            }
        }

        return result;
    }

    private static double[,] MatrixSubtract(double[,] matrix1, double[,] matrix2)
    {
        int rows = matrix1.GetLength(0);
        int cols = matrix1.GetLength(1);
        double[,] result = new double[rows, cols];

        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < cols; j++)
            {
                result[i, j] = matrix1[i, j] - matrix2[i, j];
            }
        }

        return result;
    }

    private static double[,] MatrixTranspose(double[,] matrix)
    {
        int rows = matrix.GetLength(0);
        int cols = matrix.GetLength(1);
        double[,] transposed = new double[cols, rows];

        for (int i = 0; i < rows; i++)
        {
            for (int j = 0; j < cols; j++)
            {
                transposed[j, i] = matrix[i, j];
            }
        }

        return transposed;
    }
}

class Program
{
    static void Main()
    {
        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();

        double[,] priceMatrix = PortfolioRiskCalculator.ReadCsv("portfolio4indices.csv");
        double[] portfolio = { 4000, 3000, 1000, 2000 };

        // Historical Simulation
        double[] loss = PortfolioRiskCalculator.CalculateLoss(priceMatrix, portfolio);
        var traditional = PortfolioRiskCalculator.Traditional(loss);
        Console.WriteLine($"Traditional\nVaR: {traditional.VaR:F5}, ES: {traditional.ES:F5},\nVaR Lower: {traditional.VaRLower:F5}, VaR Upper: {traditional.VaRUpper:F5}\n");

        var traditionalWeighting = PortfolioRiskCalculator.TraditionalWeighting(loss);
        Console.WriteLine($"\nTraditional Weighting\nVaR: {traditionalWeighting.VaR:F5}, ES: {traditionalWeighting.ES:F5}\n");

        var adjustedLoss = PortfolioRiskCalculator.AdjustedLoss(loss);
        Console.WriteLine($"\nAdjusted Loss\nVaR: {adjustedLoss.VaR:F5}, ES: {adjustedLoss.ES:F5}\n");

        var volatilityScaling = PortfolioRiskCalculator.VolatilityScaling(priceMatrix, portfolio);
        Console.WriteLine($"\nVolatility Scaling\nVaR: {volatilityScaling.VaR:F5}, ES: {volatilityScaling.ES:F5}\n");

        // Model Building
        double[,] returnMatrix = PortfolioRiskCalculator.GetReturnMatrix(priceMatrix);

        var equalWeight = PortfolioRiskCalculator.EqualWeight(returnMatrix, portfolio);
        Console.WriteLine($"\nEqual Weight\nVaR: {equalWeight.VaR:F5}, ES: {equalWeight.ES:F5}\n");

        var eWMA = PortfolioRiskCalculator.EWMA(returnMatrix, portfolio);
        Console.WriteLine($"\nEWMA\nVaR: {eWMA.VaR:F5}, ES: {eWMA.ES:F5}\n");

        stopwatch.Stop();
        Console.WriteLine($"\nElapsed time: {stopwatch.Elapsed.TotalSeconds} 秒");
    }
}
