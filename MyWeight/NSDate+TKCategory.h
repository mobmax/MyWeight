
#import <Foundation/Foundation.h>


struct TKDateInformation {
	int day;
	int month;
	int year;
	
	int weekday;
	
	int minute;
	int hour;
	int second;
	
};
typedef struct TKDateInformation TKDateInformation;

@interface NSDate (TKCategory)

+ (NSDate *) yesterday;
+ (NSDate *) tomorrow;
+ (NSDate *) month;
+ (NSDate *) week;
+ (NSDate *) nextWeek;
+ (NSDate *) nextMonth;
+ (NSDate *) today;

- (NSDate *) nextDate;
- (NSDate *) monthDate;
- (NSDate *) weekDate;
- (NSDate *) nextWeekDate;
- (NSDate *) lastOfMonthDate;
- (NSDate *) startOfNextWeek;
- (NSDate *) prevWeekDate;


- (NSDate*) timelessDate;

- (BOOL) isSameDay:(NSDate*)anotherDate;
- (int) monthsBetweenDate:(NSDate *)toDate;
- (NSInteger) daysBetweenDate:(NSDate*)d;
- (BOOL) isToday;


- (NSDate *) dateByAddingDays:(NSUInteger)days;
+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime;

- (NSString *) monthString;
- (NSString *) yearString;
- (NSString *) shortDateString;
- (NSString *) shortTimeString;
- (NSString *) mediumDateString;
- (NSString *) mediumDateStringMinusYear;

- (TKDateInformation) dateInformation;
- (TKDateInformation) dateInformationWithTimeZone:(NSTimeZone*)tz;
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info;
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info timeZone:(NSTimeZone*)tz;
+ (NSString*) dateInformationDescriptionWithInformation:(TKDateInformation)info;


@end
