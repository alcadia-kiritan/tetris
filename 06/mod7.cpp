#include <iostream>
#include <cassert>
#include <algorithm>

//nbitシフトするコスト
int ShiftCost(int n)
{
	return std::min({ n , std::abs(n - 8), std::abs(n - 16) });
}

//ある数を足すコスト
int AddCost(int x)
{
	return x != 0 ? 1 : 0;
}

//１になってるビット数を返す
int BitCount(int x)
{
	int count = 0;
	for (; x != 0; ++count)
		x &= x - 1;
	return count;
}

//ある数値をシフトと加算で単純に作成するときのコスト
int _MulCost(int x)
{
	//最上位以降は全部1になる数値を生成
	int y = x;
	y |= y >> 1;
	y |= y >> 2;
	y |= y >> 4;
	y |= y >> 8;
	y |= y >> 16;

	//最上位ビットまでシフトするコストと、ビットが立ってるところで加算するコスト
	return BitCount(y) - 1 + BitCount(x) - 1;
}

static int s_mulCostCache[0x10000];

//ある数値との掛け算を、加算減算シフト色々混ぜて生成するコスト
int MulCost(int x, int limit = 32)
{
	assert((size_t)x < std::size(s_mulCostCache));

	if (s_mulCostCache[x] >= 0)
		return s_mulCostCache[x];

	if (x <= 1)
		return s_mulCostCache[x] = 0;

	//単純にビット立ってるところで足すコストとシフトするコスト
	int bestCost = _MulCost(x);

	if (--limit < 0)
		return bestCost;

	//１回加算/減算した数値を経由したときの生成コスト
	bestCost = std::min({ bestCost, MulCost(x - 1, limit) + 1, MulCost(x + 1, limit) + 1 });

	//１回シフトした数値を経由したときのコスト
	if (x & 1)
	{
		bestCost = std::min({ bestCost, MulCost(x >> 1, limit) + 2 });
	}
	else
	{
		bestCost = std::min({ bestCost, MulCost(x >> 1, limit) + 1 });
	}

	for (int s = 1; s <= 8; ++s)
	{
		//sビットまで生成

		int smask = (1 << s) - 1;
		int scost = MulCost(x & smask, limit);

		if (scost > bestCost)
			continue;

		for (int t = 1; t <= 10; ++t)
		{
			//それをtbitシフトして

			int tcost = scost + ShiftCost(t);

			if (tcost > bestCost)
				continue;

			int y = (x & smask) << t;

			//さらに生成した奴か元の数値を加算か減算か何もしない

			for (int i = 0; i < 9; ++i)
			{
				int s0 = i / 3 - 1;
				int r0 = i % 3 - 1;

				if (x == y + s0 * (x & smask) + r0)
				{
					int cost =
						tcost					//sの生成コストとtビットシフトコスト
						+ (s0 != 0 ? 2 : 0)		//sの保持(strz)コストと加算or減算コスト
						+ (r0 != 0 ? 1 : 0);	//元の数値の加算or減算コスト

					if (cost < bestCost)
						bestCost = cost;
				}
			}
		}
	}

	return s_mulCostCache[x] = bestCost;
}

//引数divでの割り算を、掛け算とビットシフトで表現できるパラメータを探す
void SearchDivParam(int div)
{
	int bestCost = 512;

	for (int shift = 0; shift <= 16; ++shift)
	{
		int magicBase = (1 << shift) / div;

		for (int magicOffset = -magicBase; magicOffset <= magicBase; ++magicOffset)
		{
			int magic = magicBase + magicOffset;

			if (magic * 255 > 0xFFFF)
				break;		//16bitを超えてるのでこれ以上大きい数値は調べない

			int mcCost = MulCost(magic) + ShiftCost(shift);

			if (bestCost < mcCost)
				continue;

			for (int offset = -magic; offset <= magic; ++offset)
			{
				int cost = mcCost + AddCost(offset);

				if (bestCost < cost)
					continue;

				bool correct = true;

				for (int x = 0; x <= 255; ++x)
				{
					int a = (x * magic + offset) >> shift;

					if (x / div != a)
					{
						correct = false;
						break;
					}
				}

				if (correct)
				{
					bestCost = cost;
					std::cout << "div" << div << "(x) = (x * " << magic << " + " << offset << ") >> " << shift << "  Cost:" << cost << " MCost:" << MulCost(magic) << " SCost:" << ShiftCost(shift) << std::endl;
					break;
				}
			}
		}
	}
}

void SimpleSearchDivParam(int div)
{
	for (int shift = 0; shift <= 16; ++shift)
	{
		int magic = (1 << shift) / div;

		for (int offset = -magic+1; offset < magic; ++offset)
		{
			bool correct = false;

			for (int x = 0; x <= 255; ++x)
			{
				int a = (x * magic + offset) >> shift;

				if (x / div != a)
				{
					correct = false;
					break;
				}
			}

			if (correct)
			{
				std::cout << "div" << div << "(x) = (x * " << magic << " + " << offset << ") >> " << shift << std::endl;
				return;
			}
		}
	}
}

static const uint8_t s_mod7Table[] = {
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3
};

//テーブルver
uint8_t Mod7_Table(uint8_t x)
{
	return s_mod7Table[x];
}

static const uint8_t s_mod7Table130[] = {
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3, 
};

//テーブル半減ver
uint8_t Mod7_HalfTable(uint8_t x)
{
	if (x >= 18 * 7) x -= 18 * 7;	// <= 129
	return s_mod7Table130[x];
}

static const uint8_t s_mod7Table67[] = {
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6, 0,1,2,3,4,5,6,
	0,1,2,3,4,5,6, 0,1,2,3,
};

//テーブル４分の１ver
uint8_t Mod7_QuarterTable(uint8_t x)
{
	if (x >= 18 * 7) x -= 18 * 7;	// <= 129
	if (x >= 9 * 7) x -= 9 * 7;		// <= 66
	return s_mod7Table67[x];
}

//引き算のみに還元したver
uint8_t Mod7_SubOnly(uint8_t x)
{
	if (x >= 18 * 7) x -= 18 * 7;	// <= 129
	if (x >= 9 * 7) x -= 9 * 7;		// <= 66
	if (x >= 5 * 7) x -= 5 * 7;		// <= 34
	if (x >= 2 * 7) x -= 2 * 7;		// <= 20
	if (x >= 1 * 7) x -= 1 * 7;		// <= 13
	if (x >= 1 * 7) x -= 1 * 7;		// < 7
	return x;
}

static const uint8_t s_mod7TablePack[] = {
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 0x54, 0x06, 0x21, 0x43, 0x65,
	0x10, 0x32, 
};

//テーブルサイズを半減させたver, 4bitシフトがあるので良くない
uint8_t Mod7_TablePack(uint8_t x)
{
	uint8_t y = s_mod7TablePack[x >> 1];
	if (x & 1) y >>= 4;
	return y & 7;
}


//掛け算とシフトで/7を再現するver
uint8_t Mod7_Shift(uint8_t x)
{
	uint8_t div7 = (uint8_t)((x * 73 + 36) >> 9);
	uint8_t mod7 = x - div7 * 7;
	return mod7;
}

//https://graphics.stanford.edu/~seander/bithacks.html#ModulusDivision
//SUGEEEE
uint8_t Mod7_FromNet(uint8_t n)
{
	uint8_t mod;

	for (mod = n; n > 7; n = mod)
	{
		for (mod = 0; n; n >>= 3)
		{
			mod += n & 7;
		}
	}

	if (mod == 7)
		mod = 0;

	return mod;
}

//オーバーフローするまで７を引き続ける
uint8_t Mod7_SubLoop(uint8_t x)
{
	uint8_t y;

	do
	{
		y = x;
		x -= 7;
	} 	
	while (y > x);

	x += 7;
	return x;
}

//アルカディアの画面に表示される奴と同じ並びを表示する用
void PrintArcadiaMod7()
{
	for (uint8_t i = 0, n = 0; i < 26; ++i)
	{
		for (int j = 0; j < 16; ++j)
		{
			std::cout << (n++ % 7) << " ";
		}

		std::cout << std::endl;
	}
}

//ミスの確認用
int Failed32(int i)
{
	return i < 32 ? i % 7 : i;
}

template< typename Function >
void Mod7Test(Function mod7 )
{
	for (int i = 0; i < 256; ++i)
	{
		if ((int)mod7(i) != i % 7)
		{
			std::cout << "NG mod7(" << i << ") Failed!" << std::endl;
			return;
		}
	}

	std::cout << "OK" << std::endl;
}

int main()
{
	PrintArcadiaMod7();

	std::fill(std::begin(s_mulCostCache), std::end(s_mulCostCache), -1);
	SearchDivParam(7);
	SimpleSearchDivParam(7);

	//Mod7Test(Failed32);
	Mod7Test(Mod7_Table);
	Mod7Test(Mod7_HalfTable);
	Mod7Test(Mod7_QuarterTable);
	Mod7Test(Mod7_TablePack);
	Mod7Test(Mod7_SubOnly);
	Mod7Test(Mod7_Shift);
	Mod7Test(Mod7_FromNet);
	Mod7Test(Mod7_SubLoop);
	
	return 0;
}
