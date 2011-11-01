#!/usr/bin/env objj

@import <Foundation/CPBundle.j>
@import <SCKit/SCString.j>

function _testValues(self, template, values, expectedString)
{
    var actualString = [SCString stringWithTemplate:template, values];        

    [self assertTrue:(expectedString === actualString)
             message:"stringWithTemplate: expected:" + expectedString + " actual:" + actualString];
}

var dateFunctions = [[CPBundle bundleForClass:[SCString class]] pathForResource:@"date-functions.js"];

// Strip the file: transport from the path
dateFunctions = dateFunctions.substring(dateFunctions.indexOf("/"));
require(dateFunctions);


@implementation SCStringTest : OJTestCase

- (void)testStringWithTemplateVariableSubstitutionWithArgs
{
    var expectedString = @"There are 7 pizzas",
        template = @"There are $0 $1",
        actualString = [SCString stringWithTemplate:template, 7, @"pizzas"];

    [self assertTrue:(expectedString === actualString)
             message:"stringWithTemplate: expected:" + expectedString + " actual:" + actualString];
}

- (void)testStringWithTemplateVariableSubstitutionWithValues
{
    var expectedString = @"There are 7 pizzas",
        template = @"There are $qty $item";
        
    _testValues(self, template, {qty:7, item:"pizzas"}, expectedString);
}

- (void)testStringWithTemplateVariableSubstitutionWithDefaults
{
    var expectedString = @"There are 7 pizzas",
        template = @"There are ${qty|7} ${item|pizzas}";

    _testValues(self, template, {}, expectedString);
}

- (void)testStringWithTemplateZeroSelector
{
    var expectedString = @"There are no pizzas",
        template = @"There are #qty#no#$qty# $item",
        values = {qty:0, item:"pizzas"};
        
    _testValues(self, template, values, expectedString);

    expectedString = @"There are 7 pizzas";
    values.qty = 7;
    _testValues(self, template, values, expectedString);
}

- (void)testStringWithTemplatePluralSelector
{
    var expectedString = @"There is 1 pizza",
        template = @"There |qty|is|are| #qty#no#$qty# ${item}|qty||s|",
        values = {qty:1, item:"pizza"};

    _testValues(self, template, values, expectedString);
             
    expectedString = @"There are 7 pizzas";
    values.qty = 7;
    _testValues(self, template, values, expectedString);
}

- (void)testStringWithTemplateNumberFormats
{
    var expectedString = @"There are 7 pizzas",
        template = @"There are ${qty:d} pizzas",
        values = {qty:7.07};
        
    _testValues(self, template, values, expectedString);
             
    expectedString = @"There are 7.1 pizzas";
    template = @"There are ${qty:.1f} pizzas";
    _testValues(self, template, values, expectedString);
             
    expectedString = @"There are 7.07 pizzas";
    template = @"There are ${qty:.2f} pizzas";
    _testValues(self, template, values, expectedString);
                 
    expectedString = @"There are 0.270 pizzas";
    template = @"There are ${qty:0.3f} pizzas";
    values.qty = 0.27;
    _testValues(self, template, values, expectedString);
}

- (void)testStringWithTemplateDateFormats
{
    var expectedString = @"Date (YYYY-MM-DD): 1964-04-13",
        template = @"Date (YYYY-MM-DD): ${date:Y-m-d}",
        values = {date: new Date(1964, 3, 13)};
        
    _testValues(self, template, values, expectedString);

    expectedString = @"Date (Weekday, Month Date, Year): Monday, April 13, 1964",
    template = @"Date (Weekday, Month Date, Year): ${date:l, F j, Y}",
    _testValues(self, template, values, expectedString);
}

@end

// 
// var template = @"There |qty|is|are| #qty#no#${qty}# ${name}|qty||s|#qty#!##",
//     values = {name:"pizza", qty:0};
// 
// print([SCString stringWithTemplate:template, values]);
// values.qty = 1;
// print([SCString stringWithTemplate:template, values]);
// values.qty = 7;
// print([SCString stringWithTemplate:template, values]);
// 
// print([SCString stringWithTemplate:@"The date is ${date:j F, Y}", {date:new Date()}]);
