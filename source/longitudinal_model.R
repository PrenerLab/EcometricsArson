m1 <- lm(arson_rate ~ violent_rate + larceny_rate, data = crime)
summary(m1)
