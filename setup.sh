#!/usr/bin/env bash
echo "== Script de setup da atividade =="
read -rp "Digite seu usuário GitHub: " GH_USER
REPO_NAME="junit-atv2-template-carteiraDigital"
REPO_URL="https://github.com/${GH_USER}/${REPO_NAME}.git"

if [ -d "${REPO_NAME}" ]; then
  cd "${REPO_NAME}"
  git pull
else
  git clone "${REPO_URL}"
  cd "${REPO_NAME}"
fi

mkdir -p src/test/java

cat > src/test/java/DigitalWalletTest.java <<'JAVA'
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assumptions.*;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.jupiter.params.provider.Arguments;

import java.util.stream.Stream;

@DisplayName("Testes da DigitalWallet")
class DigitalWalletTest {

    private DigitalWallet newVerifiedUnlockedWallet(double initialBalance) {
        DigitalWallet w = new DigitalWallet("Carlos", initialBalance);
        w.verify();
        w.unlock();
        return w;
    }

    @Test
    void constructorSetsInitialBalance() {
        DigitalWallet w = new DigitalWallet("Carlos", 100.0);
        assertEquals(100.0, w.getBalance(), 0.0001);
    }

    @Test
    void constructorWithNegativeBalanceThrows() {
        assertThrows(IllegalArgumentException.class,
                () -> new DigitalWallet("Carlos", -0.01));
    }

    @ParameterizedTest
    @ValueSource(doubles = {10.0, 0.01, 999.99})
    void depositValidValues(double amount) {
        DigitalWallet w = new DigitalWallet("Carlos", 50.0);
        w.deposit(amount);
        assertEquals(50.0 + amount, w.getBalance(), 0.0001);
    }

    @Test
    void depositWithZeroOrNegativeThrows() {
        DigitalWallet w = new DigitalWallet("Carlos", 0.0);
        assertAll(
            () -> assertThrows(IllegalArgumentException.class, () -> w.deposit(0.0)),
            () -> assertThrows(IllegalArgumentException.class, () -> w.deposit(-5.0))
        );
    }

    @ParameterizedTest
    @CsvSource({
        "100.0, 30.0, true",
        "50.0, 80.0, false",
        "10.0, 10.0, true"
    })
    void payHappyAndInsufficient(double initial, double toPay, boolean expected) {
        DigitalWallet w = newVerifiedUnlockedWallet(initial);
        assumeTrue(w.isVerified());
        assumeTrue(!w.isLocked());

        double before = w.getBalance();
        boolean result = w.pay(toPay);

        assertEquals(expected, result);
        if (expected) {
            assertEquals(before - toPay, w.getBalance(), 0.0001);
        } else {
            assertEquals(before, w.getBalance(), 0.0001);
        }
    }

    @Test
    void payNonPositiveThrows() {
        DigitalWallet w = newVerifiedUnlockedWallet(100.0);
        assertAll(
            () -> assertThrows(IllegalArgumentException.class, () -> w.pay(0.0)),
            () -> assertThrows(IllegalArgumentException.class, () -> w.pay(-10.0))
        );
    }

    @Test
    void refundValidIncreasesBalance() {
        DigitalWallet w = newVerifiedUnlockedWallet(20.0);
        assumeTrue(w.isVerified());
        assumeTrue(!w.isLocked());

        w.refund(5.5);
        assertEquals(25.5, w.getBalance(), 0.0001);
    }

    @Test
    void refundZeroOrNegativeThrows() {
        DigitalWallet w = newVerifiedUnlockedWallet(20.0);
        assertAll(
            () -> assertThrows(IllegalArgumentException.class, () -> w.refund(0.0)),
            () -> assertThrows(IllegalArgumentException.class, () -> w.refund(-1.0))
        );
    }

    static Stream<Arguments> refundSequencesProvider() {
        return Stream.of(
            Arguments.of(0.0, new double[]{1.0, 2.0, 3.0}, 6.0),
            Arguments.of(10.0, new double[]{0.5, 0.5, 9.0}, 20.0),
            Arguments.of(5.0, new double[]{4.0, 1.0}, 10.0)
        );
    }

    @ParameterizedTest
    @MethodSource("refundSequencesProvider")
    void refundSequences(double initial, double[] refunds, double expectedFinal) {
        DigitalWallet w = newVerifiedUnlockedWallet(initial);
        assumeTrue(w.isVerified());
        assumeTrue(!w.isLocked());

        for (double v : refunds) {
            w.refund(v);
        }
        assertEquals(expectedFinal, w.getBalance(), 0.0001);
    }

    @Test
    void notVerifiedStateThrowsOnPayAndRefund() {
        DigitalWallet w = new DigitalWallet("Carlos", 50.0);
        assumeFalse(w.isVerified());

        assertAll(
            () -> assertThrows(IllegalStateException.class, () -> w.pay(10.0)),
            () -> assertThrows(IllegalStateException.class, () -> w.refund(10.0))
        );
    }

    @Test
    void lockedStateThrowsOnPayAndRefund() {
        DigitalWallet w = new DigitalWallet("Carlos", 50.0);
        w.verify();
        w.lock();
        assumeTrue(w.isLocked());

        assertAll(
            () -> assertThrows(IllegalStateException.class, () -> w.pay(10.0)),
            () -> assertThrows(IllegalStateException.class, () -> w.refund(10.0))
        );
    }
}
JAVA

mvn clean test

git add -A
git commit -m "feat: adiciona DigitalWalletTest"
git push origin main

echo "== Concluído! =="
echo "Link para entregar: https://github.com/${GH_USER}/${REPO_NAME}"
