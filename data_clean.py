import xlrd
import xlwt
import datetime
import re

from lookup_table import LookupTable
from token_table import TokenTable

def step_range(start, end, step):
	while start <= end:
		yield start
		start += step

# do birthday trans
def birthday_trans(old_type):
	if len(old_type) < 7:
		return ''
	year = old_type[0:3]
	if year == '000':
		return ''
	else:
		year = str(int(year) + 1911)
		month = old_type[3:5]
		day = old_type[5:7]	
		birthdate = year + '/' + month + '/' + day
		return birthdate

def age_trans(birthdate):
	if birthdate == '':
		return ''
	else:	
		now_year = datetime.datetime.now().year
		try:
			age = now_year - int(re.split('/', birthdate)[0])
			print(int(re.split('/', birthdate)[0]))
		except ValueError as e:
			print(birthdate)
			return ''
		return age

# 對 DVAS做資料binary化 
def tokenize_sheet():
	# book file
	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/DVAS.xlsx')
	sheet = book.sheet_by_index(0)

	# output file
	output = xlwt.Workbook(encoding="utf-8")
	# two separate sheet
	output_sheet = output.add_sheet("1")
	token_sheet = output.add_sheet("2")

	output.save("/Users/brianpan/Desktop/data/DVAS_clean.xlsx")

# clean 被害人相對人, 通報表資料
def lookup_process():
	lookup_book = LookupTable('/Users/brianpan/Desktop/data/lookup_table.xlsx')
	lookup_book.set_sheet_id(1)

	lookup_book.get_basic_info()

	print(lookup_book.set_all_lookup_attributes())

	# start process
	# book = xlrd.open_workbook('/Users/brianpan/Desktop/data/通報表被害人相對人資料.xls')
	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/個案被害人相對人資料.xls')
	sheet = book.sheet_by_index(0)
	print(sheet.nrows, sheet.ncols)
	#
	output = xlwt.Workbook(encoding="utf-8")
	output_sheet = output.add_sheet("1")
	for idx in range(sheet.ncols):
		attribute = sheet.cell_value(rowx=0,colx=idx)
		print("--- {0}% Start cleaning : {1} ---".format(round((idx/sheet.ncols)*100, 2), attribute))
		if lookup_book.get_lookup_attributes(attribute) is not False:
			print(attribute)
			
			output_sheet.write(0, idx, attribute)
			lookup_attributes = lookup_book.get_lookup_attributes(attribute)
			
			# lookup loop 
			if attribute == 'MAIMED' or attribute == 'SITUATIONITEM' or attribute == 'SPECIALNOTE' or attribute == 'CASEROLE' or attribute == 'INCOMETYPE':
				for ridx in step_range(1, sheet.nrows-1, 1):
					origin_data = sheet.cell_value(rowx=ridx, colx=idx)
					if origin_data != "":
						char_list = list(origin_data)
						try:
							if len(char_list) > 1:
								modify_data = ",".join([lookup_attributes[char_idx] for char_idx in char_list])
							else:
								modify_data = lookup_attributes[char_list[0]]
						except KeyError as e:
							print("cell : {0},{1},{2} failed".format(ridx, idx, origin_data))
							output_sheet.write(ridx, idx, origin_data)
						else:
							output_sheet.write(ridx, idx, modify_data)
			else:
				
					# print(sheet.cell_value(rowx=1, colx=idx))	
				for ridx in step_range(1, sheet.nrows-1, 1):
					origin_data = sheet.cell_value(rowx=ridx, colx=idx)
					if origin_data != '':
						try:
							modify_data = lookup_attributes[str(origin_data)]
						except KeyError as e:
							print("cell : {0},{1},{2} failed".format(ridx, idx, origin_data))
							output_sheet.write(ridx, idx, origin_data)
						else:
							output_sheet.write(ridx, idx, modify_data)	
		else:
			for ridx in range(sheet.nrows):
				modify_data = sheet.cell_value(rowx=ridx, colx=idx)
				if ridx == 0:
					print('--')
				elif attribute == 'BDATE':
					modify_data = birthday_trans(modify_data)
					BDATE_IDX = idx
				elif attribute == 'AGE':
					birthdate = birthday_trans(sheet.cell_value(rowx=ridx,colx=BDATE_IDX))
					modify_data = age_trans(birthdate)
				output_sheet.write(ridx, idx, modify_data)
	

	# output.save("/Users/brianpan/Desktop/data/通報表被害人相對人資料_clean.xls")
	output.save("/Users/brianpan/Desktop/data/個案被害人相對人資料_clean.xls")
# load lookup table
if __name__ == "__main__":



