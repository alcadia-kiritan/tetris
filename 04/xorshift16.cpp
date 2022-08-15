#include <iostream>
#include <set>
#include <map>
#include <random>
#include <numeric>
#include <bit>
#include <cassert>

//参考にしたサイト
//http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
uint16_t xorshift16()
{
	static uint16_t x = 0x1212;
	x ^= x << 7;
	x ^= x >> 9;
	x ^= x << 8;
	return x;
}

uint8_t xorshift8()
{
	static uint8_t x = 0x1;
	x ^= x >> 1;
	x ^= x << 1;
	x ^= x >> 2;
	return x;
}

uint32_t xorshift32()
{
	static uint32_t y = 2463534242;
	y ^= y << 13;
	y ^= y >> 17;
	y ^= y << 5;
	return y;
}

//ローテート付き左シフト
uint8_t RotateLeft(uint8_t x, int shift)
{
	if (shift == 0) return x;
	uint8_t mask = (1 << shift) - 1;
	return ((x << shift) & ~mask) | ((x >> (8 - shift)) & mask);
}

uint8_t next_xorshift8( uint8_t r0 )
{
	uint8_t r1;

	r0 = RotateLeft(r0, 1);
	r1 = r0;

	r1 = RotateLeft(r1, 1) & 95;
	r0 ^= r1;

	return r0;
}

uint8_t double_xorshift8()
{
	static uint8_t x = 0x01;
	static uint8_t y = 0x01;

	x = next_xorshift8(x);

	if (x == 1)
		y = next_xorshift8(y);

	return x ^ y;
}

uint8_t double_xorshift8_v2()
{
	static uint8_t x = 0x01;
	static uint8_t y = 0x00;

	x = next_xorshift8(x);

	if (x == 1)
		++y;

	return x ^ y;
}

//周期のテスト
template< typename RandomGenerator >
void TestCycle(RandomGenerator generator)
{
	std::set<uint32_t> values;

	//周期の３倍ぐらい回してみる
	for (int i = 0; i < 0x10000 * 3; ++i)
	{
		uint32_t r = generator();

		//最初の３２個だけ表示してみる
		if (i < 32)
			std::cout << std::hex << r << std::endl;

		if (!values.insert(r).second)
		{
			//同じ数値が出た. 周期を表示してみる
			std::cout << "cycle " << values.size() << std::endl;
			values.clear();
		}
	}
}

//ガチ乱数で0～6を返す
int GetRandomTetriminoType()
{
	static std::random_device seed;
	static std::mt19937 engine(seed());
	static std::uniform_int_distribution<> generator(0, 6);
	return generator(engine);
}

//RandomGeneratorで返された乱数の下位8bitから、その区間に応じて０～６を返すファンクタ
template< typename RandomGenerator >
struct GetRandomTetriminoSimple
{
	GetRandomTetriminoSimple(RandomGenerator generator) : generator(generator) {}

	RandomGenerator generator;

	int operator()()
	{
		uint8_t random = (uint8_t)generator();

		if (random < 36 * 1 + 1) return 0;
		if (random < 36 * 2 + 1) return 1;
		if (random < 36 * 3 + 2) return 2;
		if (random < 36 * 4 + 2) return 3;
		if (random < 36 * 5 + 3) return 4;
		if (random < 36 * 6 + 3) return 5;
		return 6;
	}
};

//RandomGeneratorで返された乱数の下位8bitから、その区間に応じて０～６を返すファンクタ。均一になるように乱数を再生成している。
template< typename RandomGenerator >
struct GetRandomTetriminoUniformedSimple
{
	GetRandomTetriminoUniformedSimple(RandomGenerator generator) : generator(generator), maxLoop(0) {}

	RandomGenerator generator;
	int maxLoop;

	int operator()()
	{
		uint8_t random;

		int loop = 0;

		do
		{
			random = (uint8_t)generator();
			++loop;
		}
		while (random >= 252);


		if (maxLoop < loop)
		{
			//std::cout << "MaxLoop " << loop << std::endl;		//多くて４回ぐらい
			maxLoop = loop;
		}

		if (random < 36 * 1) return 0;
		if (random < 36 * 2) return 1;
		if (random < 36 * 3) return 2;
		if (random < 36 * 4) return 3;
		if (random < 36 * 5) return 4;
		if (random < 36 * 6) return 5;
		return 6;
	}
};

//RandomGeneratorで返された乱数の下位8bitから、７の剰余をとって０～６を返すファンクタ。
template< typename RandomGenerator >
struct GetRandomTetriminoMod7
{
	GetRandomTetriminoMod7(RandomGenerator generator) : generator(generator) {}

	RandomGenerator generator;

	int operator()()
	{
		return generator() % 7;
	}
};

////RandomGeneratorで返された乱数の下位8bitから、７の剰余をとって０～６を返すファンクタ。均一になるように乱数を再生成している。
template< typename RandomGenerator >
struct GetRandomTetriminoUniformedMod7
{
	GetRandomTetriminoUniformedMod7(RandomGenerator generator) : generator(generator) {}

	RandomGenerator generator;

	int operator()()
	{
		uint8_t random;

		do
		{
			random = (uint8_t)generator();
		} 		
		while (random >= 252);

		return random % 7;
	}
};

////RandomGeneratorで返された乱数の下位3bitが、６以下であればそれを返し、７であれば０～６を周期的に返す。
template< typename RandomGenerator >
struct GetRandomTetriminoAnd7
{
	GetRandomTetriminoAnd7(RandomGenerator generator) : generator(generator), remain(0)
	{}

	
	RandomGenerator generator;
	int remain;

	int operator()()
	{
		uint8_t random = (uint8_t)generator() & 7;
		
		if (random <= 6)
			return random;

		if (++remain >= 7)
			remain = 0;
		
		return remain;
	}
};


//標準偏差と平均を計算するクラス
struct StdCalculator
{
	double sum;
	double variance;
	int n;

	StdCalculator() : sum(0.0), variance(0.0), n(0)
	{}

	void Add(int i)
	{
		double oldMean = n > 0 ? sum / n : 0.0;

		sum += i;
		++n;

		double newMean = sum / n;

		variance = ((double)(n - 1) * (variance + oldMean * oldMean) + (double)i * i) / n - newMean * newMean;
	}

	double CalcAve()
	{
		return sum / n;
	}

	double CalcStd()
	{
		return std::sqrt(std::max(variance, 0.0));
	}
};

//０～６をランダムに返す関数RandomGeneratorをテストする関数
template< typename RandomGenerator >
void TestTetriminoGenerator( RandomGenerator generator )
{
	int tetriminoCount[7] = { 0, };
	std::vector<int> tupleCount(7 * 7, 0);
	std::vector<int> tripleCount(7 * 7 * 7, 0);

	int prevType = 0;

	for (int loop = 0; loop < 0xFFFF * 128; ++loop)
	//for (int loop = 0; loop < 0xFFFF * 8; ++loop)
	//for (int loop = 0; loop < 0x3FF; ++loop)
	{
		int type = generator();
		++tetriminoCount[type];

		assert(0 <= type && type < 7);

		prevType = (prevType * 7) + type;
		prevType %= 7 * 7 * 7;

		++tupleCount[prevType % (7 * 7)];
		++tripleCount[prevType];
	}

	//ブロック１個ずつで見たときの出現回数
	{
		int max = INT_MIN;
		int min = INT_MAX;
		StdCalculator std;

		for( size_t i = 0; i < std::size(tetriminoCount); ++i )
		{
			int n = tetriminoCount[i];
			max = std::max(max, n);
			min = std::min(min, n);
			std.Add(n);
			//std::cout << i << " " << n << std::endl;
		}

		double sd = std.CalcStd();
		double ave = std.CalcAve();
		std::cout << "1";
		std::cout << " max/min " << ((double)max / min) << " std/ave " << (sd / ave * 100) << " max/ave " << ((double)max/ave) << " min/ave " << ((double)min/ave) << std::endl;
	}

	//連続したブロック２個で見たときの出現回数
	{
		int max = INT_MIN;
		int min = INT_MAX;
		StdCalculator std;

		for (auto n : tupleCount)
		{
			max = std::max(max, n);
			min = std::min(min, n);
			std.Add(n);
		}

		double sd = std.CalcStd();
		double ave = std.CalcAve(); 
		std::cout << "2";
		std::cout << " max/min " << ((double)max / min) << " std/ave " << (sd / ave * 100) << " max/ave " << ((double)max / ave) << " min/ave " << ((double)min / ave) << std::endl;
	}

	//連続したブロック３個で見たときの出現回数
	{
		int max = INT_MIN;
		int min = INT_MAX;
		StdCalculator std;

		for (auto n : tripleCount)
		{
			max = std::max(max, n);
			min = std::min(min, n);
			std.Add(n);
		}

		double sd = std.CalcStd();
		double ave = std.CalcAve();
		std::cout << "3";
		std::cout << " max/min " << ((double)max / min) << " std/ave " << (sd / ave * 100) << " max/ave " << ((double)max / ave) << " min/ave " << ((double)min / ave) << std::endl;
	}
}

template< template <typename> typename TetriminoGenerator, typename RandomGenerator >
auto CreateGenerator(RandomGenerator g)
{
	return TetriminoGenerator<RandomGenerator>(g);
}

template< typename RandomGenerator >
void TestTetris(RandomGenerator generator)
{
	std::cout << "Simple" << std::endl;
	TestTetriminoGenerator(CreateGenerator<GetRandomTetriminoSimple>(generator));
	std::cout << "UniformedSimple" << std::endl;
	TestTetriminoGenerator(CreateGenerator<GetRandomTetriminoUniformedSimple>(generator));
	std::cout << "Mod7" << std::endl;
	TestTetriminoGenerator(CreateGenerator<GetRandomTetriminoMod7>(generator));
	std::cout << "UniformedMod7" << std::endl;
	TestTetriminoGenerator(CreateGenerator<GetRandomTetriminoUniformedMod7>(generator));
	std::cout << "And7" << std::endl;
	TestTetriminoGenerator(CreateGenerator<GetRandomTetriminoAnd7>(generator));
}

void TestTetris()
{
	std::cout << "std::mt19937" << std::endl;
	TestTetriminoGenerator(GetRandomTetriminoType);

	std::cout << "------------ xorshift8" << std::endl;
	TestTetris(xorshift8);

	std::cout << "------------ xorshift16" << std::endl;
	TestTetris(xorshift16);

	std::cout << "------------ double_xorshift8" << std::endl;
	TestTetris(double_xorshift8);

	std::cout << "------------ double_xorshift8_v2" << std::endl;
	TestTetris(double_xorshift8_v2);
	

	std::cout << "------------ xorshift32" << std::endl;
	TestTetris(xorshift32);
}


int main()
{
	//TestCycle(xorshift8);
	//TestCycle(xorshift16);
	

	TestTetris();
	return 0;
}
