
#import "NSDate+TKCategory.h"


@implementation NSDate (TKCategory)

+ (NSDate*) yesterday{
	TKDateInformation inf = [[NSDate date] dateInformation];
	inf.day--;
	return [NSDate dateFromDateInformation:inf];
}

+ (NSDate*) tomorrow{
	TKDateInformation inf = [[NSDate date] dateInformation];
	inf.day++;
	return [NSDate dateFromDateInformation:inf];
}

+ (NSDate*) month{
    return [[NSDate date] monthDate];
}

+ (NSDate*) week{
    return [[NSDate date] weekDate];
}

- (NSDate*) weekDate {
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
    [comp setWeekday:[[NSCalendar currentCalendar] firstWeekday]];
    [comp setYearForWeekOfYear:comp.year];
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    return date;
}

+ (NSDate*) nextWeek{
    return [[NSDate date] nextWeekDate];
}

- (NSDate*) nextWeekDate {
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
    comp.weekday = [[NSCalendar currentCalendar] firstWeekday];
    comp.weekOfYear = comp.weekOfYear + 1;
    [comp setYearForWeekOfYear:comp.year];
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    return date;
}

- (NSDate *) nextDate {
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    [comp setDay:comp.day+1];
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    return date;    
}

- (NSDate*) monthDate {
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
	[comp setDay:1];
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    return date;
}

- (NSDate*) lastOfMonthDate {
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    return date;
}

+ (NSDate*)nextMonth {
    NSDate *day = [NSDate date];
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

+ (NSDate*) lastOfCurrentMonth{
	NSDate *day = [NSDate date];
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

- (int) weekday{	
	NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
	int weekday = (int)[comps weekday];
	return weekday;
}

- (NSDate*) timelessDate {
	NSDate *day = self;
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:day];
	return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

- (NSDate*) monthlessDate {
	NSDate *day = self;
	NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	return [[NSCalendar currentCalendar] dateFromComponents:comp];
}

- (BOOL) isSameDay:(NSDate*)anotherDate{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
} 

- (int) monthsBetweenDate:(NSDate *)toDate{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit
                                                fromDate:[self monthlessDate]
                                                  toDate:[toDate monthlessDate]
                                                 options:0];
    int months = (int)[components month];
    return abs(months);
}

- (NSInteger)daysBetweenDate:(NSDate*)d{
	
	NSTimeInterval time = [self timeIntervalSinceDate:d];
	return abs(time / 60 / 60/ 24);
}

- (BOOL) isToday{
	return [self isSameDay:[NSDate date]];
} 



- (NSDate *) dateByAddingDays:(NSUInteger)days {
	NSDateComponents *c = [[NSDateComponents alloc] init];
	c.day = days;
	return [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:self options:0];
}

+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy"];
	NSString *datePortion = [dateFormatter stringFromDate:aDate];
	
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString *timePortion = [dateFormatter stringFromDate:aTime];
	
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
	NSString *dateTime = [NSString stringWithFormat:@"%@ %@",datePortion,timePortion];
	return [dateFormatter dateFromString:dateTime];
}


- (NSString*) monthString{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"LLLL"];
	return [dateFormatter stringFromDate:self];
}

- (NSString*) yearString{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy"];
	return [dateFormatter stringFromDate:self];
}

- (NSString *)shortDateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
	return [dateFormatter stringFromDate:self];
}

- (NSString *)shortTimeString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
	return [dateFormatter stringFromDate:self];
}

- (NSString *)mediumDateString {
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setTimeStyle:NSDateFormatterNoStyle];
    [formater setDateStyle:NSDateFormatterMediumStyle];
    return [formater stringFromDate:self];
}

- (NSString *) mediumDateStringMinusYear {
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
//    [formater setTimeStyle:NSDateFormatterNoStyle];
//    [formater setDateStyle:NSDateFormatterMediumStyle];
    [formater setDateFormat:@"LLL d"];
    return [formater stringFromDate:self];
}


- (TKDateInformation) dateInformationWithTimeZone:(NSTimeZone*)tz{
	
	
	TKDateInformation info;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tz];
	NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | 
													NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
										  fromDate:self];
	info.day = (int)[comp day];
	info.month = (int)[comp month];
	info.year = (int)[comp year];
	
	info.hour = (int)[comp hour];
	info.minute = (int)[comp minute];
	info.second = (int)[comp second];
	
	info.weekday = (int)[comp weekday];
	return info;
	
}

- (TKDateInformation) dateInformation{
	
	TKDateInformation info;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | 
													NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
										  fromDate:self];
    info.day = (int)[comp day];
    info.month = (int)[comp month];
    info.year = (int)[comp year];
    
    info.hour = (int)[comp hour];
    info.minute = (int)[comp minute];
    info.second = (int)[comp second];
    
    info.weekday = (int)[comp weekday];
    
	return info;
}

+ (NSDate*) dateFromDateInformation:(TKDateInformation)info timeZone:(NSTimeZone*)tz{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tz];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
	
	[comp setDay:info.day];
	[comp setMonth:info.month];
	[comp setYear:info.year];
	[comp setHour:info.hour];
	[comp setMinute:info.minute];
	[comp setSecond:info.second];
	[comp setTimeZone:tz];
	
	return [gregorian dateFromComponents:comp];
}

+ (NSDate*) dateFromDateInformation:(TKDateInformation)info{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
	
	[comp setDay:info.day];
	[comp setMonth:info.month];
	[comp setYear:info.year];
	[comp setHour:info.hour];
	[comp setMinute:info.minute];
	[comp setSecond:info.second];
	//[comp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	return [gregorian dateFromComponents:comp];
}

+ (NSString*) dateInformationDescriptionWithInformation:(TKDateInformation)info{
	return [NSString stringWithFormat:@"%d %d %d %d:%d:%d",info.month,info.day,info.year,info.hour,info.minute,info.second];
}

@end
