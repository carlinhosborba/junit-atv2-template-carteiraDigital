public class DigitalWallet {
    private final String owner;
    private double balance;
    private boolean verified;
    private boolean locked;

    public DigitalWallet(String owner, double initialBalance) {
        if (initialBalance < 0) {
            throw new IllegalArgumentException("Initial balance must be >= 0");
        }
        this.owner = owner;
        this.balance = initialBalance;
        this.verified = false;
        this.locked = false;
    }

    public String getOwner() { return owner; }
    public double getBalance() { return balance; }
    public boolean isVerified() { return verified; }
    public boolean isLocked() { return locked; }

    public void verify() { this.verified = true; }
    public void lock() { this.locked = true; }
    public void unlock() { this.locked = false; }

    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Deposit must be > 0");
        }
        balance += amount;
    }

    public boolean pay(double amount) {
        ensureUsable(); // verificada e não bloqueada
        if (amount <= 0) {
            throw new IllegalArgumentException("Payment must be > 0");
        }
        if (balance >= amount) {
            balance -= amount;
            return true;
        }
        return false;
    }

    public void refund(double amount) {
        ensureUsable(); // verificada e não bloqueada
        if (amount <= 0) {
            throw new IllegalArgumentException("Refund must be > 0");
        }
        balance += amount;
    }

    private void ensureUsable() {
        if (!verified) {
            throw new IllegalStateException("Wallet must be verified");
        }
        if (locked) {
            throw new IllegalStateException("Wallet is locked");
        }
    }
}
